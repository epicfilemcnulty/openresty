FROM alpine:3.17 as builder
LABEL maintainer="vladimir@deviant.guru"

COPY scripts/builder.sh /root/
RUN /root/builder.sh
COPY apk/ /root/
RUN cd /root/openresty && abuild -F checksum && abuild -F -r
RUN apk add /root/built/root/x86_64/openresty-1.21.4.1-r1.apk
RUN cd /root/luarocks && abuild -F checksum && abuild -F -r


FROM git.deviant.guru/images/lilu:latest as lilu

FROM alpine:3.17
LABEL maintainer="vladimir@deviant.guru"

COPY --from=builder /root/.abuild/vladimir@deviant.guru-*.rsa.pub /etc/apk/keys/
COPY --from=builder /root/built/root/x86_64/openresty-1.21.4.1-r1.apk /root/
COPY --from=builder /root/built/root/x86_64/luarocks-3.3.1-r1.apk /root/
COPY /src/libcidr-1.2.3.tar.xz /tmp/
COPY --from=lilu /lilu /usr/local/bin/lilu
COPY scripts/openresty.sh /root/

RUN /root/openresty.sh && rm /root/openresty.sh
COPY /src/dns.lua /usr/openresty/luajit/share/lua/5.1/
COPY supervisor.lua /

ENTRYPOINT ["/supervisor.lua"]
