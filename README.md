# Proxy

## Introduction
Set of scripts to deploy an Nginx proxy with letsencrypt certificates to serve everything over SSL.

## Configuration

### Configuration file
The configuration for the entire setup is described in a YAML file.
Create `config.yml` at the root of the repo.

Here is an config example with the expected structure
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
  sub4.domain.com:
    /: redirect:https://domain.com
```

Run `gen-config.sh` in `bin/`.
This will generate the configuration files for both Nginx and letsencrypt.

### Start Nginx
Start the proxy by using docker-compose at the root of the repo.
`docker-compose up -d`

### Generate the certificates
Execute `certonly.sh` in `bin/` to create the certificates with letsencrypt.

### Reconfigure Nginx
Execute `gen-config.sh` in `bin/` once more to have the new configuration for Nginx (with SSL).

To force Nginx to reload its configuration, you can execute `reload-nginx.sh` in `bin/`

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

## Serving files

Let's imagine that you need to serve some files for the subdomain `files.domain.com`

First let's create a `static` folder at the root of the repo.
Inside it, create a `myfiles` folder and put your files inside.
```
/
  bin/
    ...
  data/
    ...
  static/
    myfiles/
      some.file.html
      some.other.file.css
      ...
```

Then edit your `config.yml` and add the following lines:
```
files.domain.com:
  /: file:///var/www/myfiles
```

We then need to make the files available at `/var/www/myfiles` inside the Nginx container. To do so edit the main `docker-compose.yml` file at the root of the repo and add a line to the `volumes` key.
```
- ./static/myfiles:/var/www/myfiles:ro
```

Once this is done, don't forget to reconfigure and reload Nginx by executing (in the `bin/` folder):

```
./gen-config.sh
./reload-nginx.sh
```
