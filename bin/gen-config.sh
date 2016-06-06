#!/usr/bin/env bash
docker run --rm -it -v "$(pwd)/..:/app" -w /app ruby ruby ./bin/gen-config.rb
