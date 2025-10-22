import boto3, json, os, datetime

def utc_now_compact():
    return datetime.datetime.utcnow().strftime("%Y%m%d-%H%M")

def main():
    session = boto3.Session(profile_name=os.getenv("AWS_PROFILE"))
    ec2 = session.client("ec2")

    # 1) Find one running instance and one attached volume
    res = ec2.describe_instances(
        Filters=[{"Name":"instance-state-name","Values":["running"]}]
    )
    ires = [r for r in res.get("Reservations", []) if r.get("Instances")]
    if not ires:
        print(json.dumps({"error":"no running instances found"})); return
    inst = ires[0]["Instances"][0]
    iid  = inst["InstanceId"]

    # gather non-ephemeral EBS volumes attached to this instance
    vols = [m["Ebs"]["VolumeId"] for m in inst.get("BlockDeviceMappings", []) if "Ebs" in m]
    if not vols:
        print(json.dumps({"error":f"no EBS volumes on {iid}"})); return

    vol  = vols[0]  # first volume only for this step
    name = f"{vol}-{utc_now_compact()}-auto"

    # 2) Create snapshot and wait until completed
    snap = ec2.create_snapshot(VolumeId=vol, Description=name)
    sid  = snap["SnapshotId"]
    ec2.get_waiter("snapshot_completed").wait(SnapshotIds=[sid])

    # 3) Tag snapshot
    ec2.create_tags(Resources=[sid], Tags=[
        {"Key":"CreatedBy","Value":"auto-snapshot"},
        {"Key":"Name","Value":name},
        {"Key":"VolumeId","Value":vol},
        {"Key":"InstanceId","Value":iid},
    ])

    # 4) Print JSON log
    print(json.dumps({
        "snapshot_id": sid,
        "volume_id": vol,
        "instance_id": iid,
        "name": name,
        "status": "completed"
    }))
    
if __name__ == "__main__":
    main()
