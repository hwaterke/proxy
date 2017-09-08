#!/usr/bin/env bash
docker run -it --rm --name certbot \
  -v "$(pwd)/../data/letsencrypt/etc/letsencrypt:/etc/letsencrypt" \
  -v "$(pwd)/../data/letsencrypt/var/lib/letsencrypt:/var/lib/letsencrypt" \
  -v "$(pwd)/../data/letsencrypt/cli.ini:/letsencrypt.ini" \
  -v "$(pwd)/../data/letsencrypt_challenges:/var/www/letsencrypt" \
  certbot/certbot renew
