FROM alpine:3.11 as builder
LABEL maintainer="vladimir@deviant.guru"

COPY scripts/builder.sh /root/
RUN /root/builder.sh
COPY apk/ /root/
RUN cd /root/openresty && abuild -F checksum && abuild -F -r
RUN apk add /root/built/root/x86_64/openresty-1.15.8.2-r1.apk
RUN cd /root/luarocks && abuild -F checksum && abuild -F -r


FROM alpine:3.11
LABEL maintainer="vladimir@deviant.guru"

COPY --from=builder /root/.abuild/vladimir@deviant.guru-*.rsa.pub /etc/apk/keys/
COPY --from=builder /root/built/root/x86_64/openresty-1.15.8.2-r1.apk /root/
COPY --from=builder /root/built/root/x86_64/luarocks-2.4.2-r1.apk /root/
COPY scripts/openresty.sh /root/
RUN /root/openresty.sh && rm /root/openresty.sh

ENTRYPOINT ["/usr/openresty/nginx/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
