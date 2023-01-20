#!/bin/bash

{
    docker build . -t "$BASE_PATH/$REPO_NAME:$DOCKER_TAG"
    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin $REGISTRY_HOSTNAME
    docker push "$BASE_PATH/$REPO_NAME:$DOCKER_TAG"
    
} || {
    exit 1
}
rm -rf Dockerfile