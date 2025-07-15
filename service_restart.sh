#!/bin/bash

# Usage:
# ./service_restart.sh <container_name>
# OR
# ./service_restart.sh <repo_name> <tag>

if [ "$#" -eq 1 ]; then
  SERVICE_NAME="$1"
elif [ "$#" -eq 2 ]; then
  REPO_NAME="$1"
  TAG="$2"
  IMAGE="${REPO_NAME}:${TAG}"

  # Find running container using that image
  SERVICE_NAME=$(docker ps --filter "ancestor=$IMAGE" --format "{{.Names}}" | head -n1)

  if [ -z "$SERVICE_NAME" ]; then
    echo "❌ Error: No running container found for image '$IMAGE'"
    exit 1
  fi
else
  echo "❌ Error: Invalid arguments."
  echo "Usage:"
  echo "  $0 <container_name>"
  echo "  OR"
  echo "  $0 <repo_name> <tag>"
  exit 1
fi

# Get image used by container (in case it's updated)
IMAGE=$(docker inspect --format='{{.Config.Image}}' "$SERVICE_NAME")

echo "📦 Pulling latest image: $IMAGE"
docker pull "$IMAGE"

# Extract port mappings
PORT_FLAGS=$(docker inspect "$SERVICE_NAME" | jq -r '.[0].HostConfig.PortBindings // {} | to_entries[] | "-p \(.value[0].HostPort):\(.key | split("/")[0])"' | xargs)

# Extract environment variables
ENV_FLAGS=$(docker inspect --format='{{range .Config.Env}}{{printf "--env %q " .}}{{end}}' "$SERVICE_NAME")

echo "🔁 Restarting container: $SERVICE_NAME"
echo "port: $PORT_FLAGS"

# Stop and remove
docker stop "$SERVICE_NAME"
docker rm "$SERVICE_NAME"
# Recreate
CMD="docker run -d --name $SERVICE_NAME $PORT_FLAGS $ENV_FLAGS $IMAGE"
echo "▶️ Running: $CMD"
eval "$CMD"

echo "✅ Service '$SERVICE_NAME' restarted successfully."

