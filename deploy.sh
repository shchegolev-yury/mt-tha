#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <image_name> $1 <image_tag> $3 <project_name> $4 <base_url> $5 <env>"
  exit 1
fi

IMAGE_NAME=$1
IMAGE_TAG=$2
PROJECT_NAME=$3
BASE_URL=$4
ENV=$5
CONTEXT="."

echo "Building container image"
docker build --platform linux/amd64 -t "$IMAGE_NAME:$IMAGE_TAG" "$CONTEXT"
if [ $? -eq 0 ]; then
  echo "Image build $IMAGE_NAME:$IMAGE_TAG finished"
else
  echo "Failed to build image $IMAGE_NAME:$IMAGE_TAG"
  exit 1
fi

echo "Pushing image to dockerhub"
docker push $IMAGE_NAME:$IMAGE_TAG
if [ $? -eq 0 ]; then
  echo "Image $IMAGE_NAME:$IMAGE_TAG pushed"
else
  echo "Failed to push image"
  exit 1
fi

if [ "$ENV" = "dev" ]; then
  LOG_LEVEL="DEBUG"
else
  LOG_LEVEL="INFO"
fi

echo -e "project_name = \"$PROJECT_NAME\"\nenv = \"$ENV\"\nlog_level = \"$LOG_LEVEL\"\nbase_url = \"$BASE_URL\"\nimage_name = \"$IMAGE_NAME\"\nimage_tag = \"$IMAGE_TAG\"" > terraform.tfvars
terraform init
terraform apply --auto-approve


