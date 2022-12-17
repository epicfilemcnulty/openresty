#!/bin/sh
set -euo pipefail

apk add --no-cache /root/openresty-1.21.4.1-r1.apk
apk add --no-cache /root/luarocks-3.3.1-r1.apk
LUAROCKS=/usr/openresty/luajit/bin/luarocks 

apk add --no-cache git coreutils make
ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

cd /tmp
tar -xf libcidr-1.2.3.tar.xz
cd libcidr-1.2.3
make
make install

${LUAROCKS} install libcidr-ffi
${LUAROCKS} install inspect 3.1.3-0
${LUAROCKS} install pgmoon 1.15.0-1
${LUAROCKS} install djot
${LUAROCKS} install lua-resty-http 0.17.0.beta.1-0
${LUAROCKS} install lua-resty-session 3.10-1
${LUAROCKS} install lua-resty-jwt 0.2.3-0
${LUAROCKS} install lua-resty-jit-uuid 0.0.7-2

${LUAROCKS} list
apk del luarocks unzip gcc musl-dev git make
apk add --no-cache ca-certificates

rm /root/*.apk
rm -rf /tmp/*
