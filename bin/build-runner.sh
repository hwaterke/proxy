#!/bin/sh
HASH=$(git rev-parse --verify HEAD | cut -c1-6)
docker build -t runner-$HASH -f Dockerfile-runner .
