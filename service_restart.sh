#!/bin/bash

SERVICE_NAME="$1"

if [ -z "$SERVICE_NAME" ]; then
  echo "No service name provided."
  exit 1
fi

# Dummy simulation of restart
echo "Restarting Docker service: $SERVICE_NAME"
