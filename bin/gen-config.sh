#!/usr/bin/env bash
docker run --rm -it -v "$(pwd)/..:/app" -w /app ruby:alpine ruby ./bin/gen-config.rb
