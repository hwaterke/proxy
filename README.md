# Proxy

## Introduction
Set of scripts to deploy an Nginx proxy with letsencrypt certificates to serve everything over SSL.

## Configuration

### Configuration file
The configuration for the entire setup is described in a YAML file.
Create `config.yml`

The following structure is expected:
```yaml
---
email: contact@example.com
domains:
  sub1.domain.com:
    /: http://container
  sub2.domain.com:
    /: http://service:1234
    /api: http://api:1234
  sub3.domain.com:
    /: http://service:1234
    auth: http://auth/auth
    auth_error: http://auth/login
  www.domain.com:
    /: file:///data/www/static
```

Run `gen-config.sh` in `bin/`.
This will generate the configuration files for both Nginx and letsencrypt.

### Start Nginx
Start the proxy by using docker-compose in `proxy/`.
`docker-compose up`

### Generate the certificates
Execute `certonly.sh` in `bin/` to create the certificates with letsencrypt.

### Reconfigure Nginx
Execute `gen-config.sh` in `bin/` once more to have the new configuration for Nginx (with SSL).

You can use the following to force Nginx to reload its config.
`docker kill --signal=HUP nginx-proxy`

## Proxied servers
If you run your proxied servers on Docker as well, they need to join
the `proxy_default` docker network so that the proxy can talk to them.

Here is an example
```
version: '2'
networks:
  default:
    external:
      name: proxy_default
services:
  myservice:
    build: .
```

## Renew certificates
To renew the certificates, execute `renew.sh` in `bin/`.
