#!/bin/sh
# Build the image and run it locally.
set -e

IMAGE=release-please-rc-flow
docker build -t "$IMAGE" .
docker run --rm "$IMAGE"
