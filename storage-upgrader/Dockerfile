ARG VERSION=latest
FROM tezos/tezos:${VERSION}
RUN sudo apk add curl lz4 xz jq
COPY storage-upgrader.sh /
ENTRYPOINT ["/storage-upgrader.sh"]
CMD []
