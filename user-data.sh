#!/bin/bash
dnf update -y
dnf install -y httpd nc
systemctl enable --now httpd

echo "Hello World" > /var/www/html/index.html