FROM alpine:3.17.1
RUN apk add -U bash curl
COPY download.sh /usr/local/bin
ENTRYPOINT ["download.sh"]
