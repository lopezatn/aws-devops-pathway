#!/bin/bash
# Update and install Nginx
apt update -y
apt install -y nginx

# Enable and start service
systemctl enable nginx
systemctl start nginx

# Optional: custom HTML
echo "<h1>It works – EC2 + Nginx</h1>" > /var/www/html/index.html
