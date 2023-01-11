FROM alpine:3.17.1
RUN apk add -U bash curl jq
COPY download.sh /usr/local/bin
USER nobody
ENTRYPOINT ["download.sh"]
