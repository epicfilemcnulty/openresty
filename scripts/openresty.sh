#!/bin/sh

LUAROCKS=/usr/openresty/luajit/bin/luarocks 
apk add --no-cache /root/openresty-1.17.8.2-r1.apk
apk add --no-cache /root/luarocks-3.3.1-r1.apk

apk add --no-cache sqlite-dev git coreutils
ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

${LUAROCKS} install inspect
${LUAROCKS} install lsqlite3
${LUAROCKS} install pgmoon
${LUAROCKS} install lua-resty-http
${LUAROCKS} install web

apk del luarocks unzip gcc musl-dev git
rm /root/*.apk

