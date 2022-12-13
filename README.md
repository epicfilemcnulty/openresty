### [Openresty](http://openresty.org/en/) alpine-based docker image with bells & whistles

[![Build Status](https://sisyphus.deviant.guru/api/badges/images/openresty/status.svg)](https://sisyphus.deviant.guru/images/openresty)

#### Description

Dockerfile + APKBUILD files to build an opinionated openresty container image.
Openresty is built from sources (see [apk](apk) directory).
For the list of included/excluded nginx modules, see [openresty APKBUILD file](apk/openresty/APKBUILD).
The resulting image will also include the following luarocks modules:

* inspect
* pgmoon
* libcidr-ffi
* [redstats](src/redstats.lua)
* lunamark
* lua-resty-http
* lua-resty-session
* lua-resty-jwt
* lua-resty-jit-uuid

#### Usage

There is a [builtin nginx config](apk/openresty/openresty.nginx.conf).
Nginx is configured to include every `*.conf` file from `/etc/nginx/conf.d/`
(files from this dir included **above** nginx `http` config block) and 
`/etc/nginx/vhosts/` directories, so you can just mount a host directory 
with your virtual host configs to containerr’s `/etc/nginx/vhosts` directory.

If **NGINX_VHOST_TEMPLATES** environment variable is defined, before actually
starting nginx, the entrypoint script looks for files with `.tmpl` extension
in the **NGINX_VHOST_TEMPLATES** directory.

Each `.tmpl` file gets rendered by the entrypoint script, and the output goes to the file with the same name, but `.conf` extension under
`/etc/nginx/vhosts/` dir. For example, if **NGINX_VHOST_TEMPLATES** is set to `/templates` and you have `/templates/first.tmpl` template file, the rendered content will be in the `/etc/nginx/vhosts/first.conf` file.

Every occurrence of `{{ENV_VAR_NAME}}` in a template is replaced with the value of the corresponding environment variable. It’s pretty much the same
what `envsubst` does, but gettext alpine package adds 7Mb to the image. Besides, you can’t change the capture pattern in `envsubst`.

#### Origin

The origin repository is located at [git.deviant.guru](https://git.deviant.guru/images/openresty). Github copy is a mirror.
