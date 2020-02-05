#!/bin/sh

apk add --no-cache /root/openresty-1.15.8.2-r1.apk
apk add --no-cache /root/luarocks-2.4.2-r1.apk

apk add --no-cache sqlite-dev git
ln -s /usr/openresty/luajit/bin/luajit-2.1.0-beta3 /bin/lua
ln -s /usr/openresty/luajit/bin/luarocks-5.1 /bin/luarocks
ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

luarocks install inspect
luarocks install lsqlite3
luarocks install pgmoon
luarocks install lua-resty-http
luarocks install web

apk del luarocks unzip gcc musl-dev git
rm /root/*.apk

