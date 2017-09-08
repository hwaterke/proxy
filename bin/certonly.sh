#!/usr/bin/env bash

for i in ../data/letsencrypt/cli/*.ini; do
  echo ${i##*/}
  docker run -it --rm --name certbot \
    -v "$(pwd)/../data/letsencrypt/etc/letsencrypt:/etc/letsencrypt" \
    -v "$(pwd)/../data/letsencrypt/var/lib/letsencrypt:/var/lib/letsencrypt" \
    -v "$(pwd)/../data/letsencrypt/cli/${i##*/}:/letsencrypt.ini" \
    -v "$(pwd)/../data/letsencrypt_challenges:/var/www/letsencrypt" \
    certbot/certbot certonly \
    --config /letsencrypt.ini \
    --agree-tos
done
