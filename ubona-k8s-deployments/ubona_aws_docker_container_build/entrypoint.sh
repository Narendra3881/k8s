#!/bin/bash

# Perform any pre-startup tasks here
echo "Performing pre-startup tasks..."

# Start nginx
echo "Starting nginx..."
systemctl start nginx

#  Execute CMD to start the main application process
exec "$@"
