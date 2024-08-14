#!/bin/sh

docker compose up -d --build
./analytics/runStack.sh
