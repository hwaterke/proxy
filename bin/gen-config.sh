#!/usr/bin/env bash
./build-runner.sh
docker run --rm -it -v "$(pwd)/..:/app" -w /app runner ruby ./bin/gen-config.rb
