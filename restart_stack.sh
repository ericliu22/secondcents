#!/bin/sh

# Pull the latest changes from GitHub
git pull origin main

# Stop the existing Docker Compose stack
docker-compose down

# Restart the Docker Compose stack with the new changes
docker-compose up -d --build
