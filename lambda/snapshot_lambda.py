import os
import json
import datetime
import boto3

# Config
INSTANCE_STATE = os.getenv("INSTANCE_STATE", "running")
CREATED_BY     = os.getenv("CREATED_BY", "auto-snapshot")
RETENTION_DAYS = datetime.timedelta(days=7)

def utc_now():
    return datetime.datetime.now(datetime.UTC)

def utc_now_compact():
    return datetime.datetime.now(datetime.UTC).strftime("%Y%m%d-%H%M")

def handler(event, context):
    ec2 = boto3.client("ec2")
    now = utc_now()
    cutoff = now - RETENTION_DAYS

    # 1) Find instances in the desired state
    resp = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": [INSTANCE_STATE]}]
    )
    instances = [i for r in resp.get("Reservations", []) for i in r.get("Instances", [])]

    created = []

    # 2) Create snapshots for each EBS volume
    for inst in instances:
        iid = inst["InstanceId"]
        for m in inst.get("BlockDeviceMappings", []):
            if "Ebs" not in m:
                continue
            vol = m["Ebs"]["VolumeId"]
            name = f"{vol}-{utc_now_compact()}-auto"

            snap = ec2.create_snapshot(VolumeId=vol, Description=name)
            sid  = snap["SnapshotId"]

            ec2.create_tags(
                Resources=[sid],
                Tags=[
                    {"Key": "CreatedBy",  "Value": CREATED_BY},
                    {"Key": "Name",       "Value": name},
                    {"Key": "VolumeId",   "Value": vol},
                    {"Key": "InstanceId", "Value": iid},
                ]
            )
            created.append({"snapshot_id": sid, "volume_id": vol, "instance_id": iid, "name": name})

    # 3) Retention (run once, not per instance)
    to_delete = []
    snaps = ec2.describe_snapshots(
        OwnerIds=["self"],
        Filters=[{"Name": "tag:CreatedBy", "Values": [CREATED_BY]}]
    ).get("Snapshots", [])

    for s in snaps:
        if s.get("State") == "completed" and s["StartTime"] < cutoff:
            to_delete.append(s["SnapshotId"])

    for sid in to_delete:
        ec2.delete_snapshot(SnapshotId=sid)

    # 4) Structured log
    print(json.dumps({
        "created_count": len(created),
        "created": created,
        "retention": {
            "cutoff": cutoff.isoformat(),
            "candidates": len(snaps),
            "deleted_count": len(to_delete),
            "deleted_ids": to_delete
        }
    }))

    return {"ok": True, "created_count": len(created), "deleted_count": len(to_delete)}
