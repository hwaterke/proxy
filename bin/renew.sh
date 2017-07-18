#!/usr/bin/env bash
docker run -it --rm --name certbot \
  -v "$(pwd)/../data/letsencrypt/etc/letsencrypt:/etc/letsencrypt" \
  -v "$(pwd)/../data/letsencrypt/var/lib/letsencrypt:/var/lib/letsencrypt" \
  -v "$(pwd)/../data/letsencrypt/cli.ini:/letsencrypt.ini" \
  --volumes-from acme-challenge-data \
  certbot/certbot renew
