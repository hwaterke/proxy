#!/usr/bin/env bash
HASH=$(git rev-parse --verify HEAD | cut -c1-6)
docker run --rm -it -v "$(pwd)/..:/app" -w /app runner-$HASH ruby ./bin/gen-config.rb
