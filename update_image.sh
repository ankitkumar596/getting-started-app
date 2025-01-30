#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define variables
REPO_URL="https://github.com/ankitkumar596/getting-started-app.git"
CLONE_DIR="/tmp/temp_app"
IMAGE_NAME="ankitkumar0987/getting-started-todo"
DEPLOYMENT_FILE="k8s/getting-started-todo-deployment.yaml"

# Ensure BUILD_NUMBER is set
if [[ -z "$BUILD_NUMBER" ]]; then
    echo "Error: BUILD_NUMBER is not set."
    exit 1
fi

# Clone the repository
git clone "$REPO_URL" "$CLONE_DIR"

# Navigate to the cloned repository
cd "$CLONE_DIR"

# Update the image tag in the deployment file
sed -i "s|${IMAGE_NAME}:[^\" ]*|${IMAGE_NAME}:${BUILD_NUMBER}|g" "$DEPLOYMENT_FILE"

# Stage and commit the changes
git add "$DEPLOYMENT_FILE"
git commit -m "Updated the image tag to ${BUILD_NUMBER}"

# Push changes
git push origin "$(git rev-parse --abbrev-ref HEAD)"

echo "Image tag updated and changes pushed successfully."
