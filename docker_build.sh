#!/bin/bash

set -u # aborts automatically if we try to expand an undefined variable
: "$ACS_VERSION_NAME"  # tries to expand variable in a no-op context.
: "$ACS_DOCKER_VERSION"  # tries to expand variable in a no-op context.

docker build \
  -t acscommunity/acs:$ACS_DOCKER_VERSION \
  --build-arg ACS_VERSION_NAME=$ACS_VERSION_NAME \
  .
