#!/bin/sh

user=$(/usr/bin/whoami)
cd /home/$user/secondcents

# Pull the latest changes from GitHub
/usr/bin/git pull origin main

# Stop the existing Docker Compose stack
/usr/bin/docker compose down

# Restart the Docker Compose stack with the new changes
/usr/bin/docker compose up -d --build
