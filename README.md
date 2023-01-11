# Nexus Maven downloader

This docker image wraps a bash script that can download maven artifacts from
nexus repository:

```
docker run --rm -it ghcr.io/mikroways/nexus-maven-download
```
> If environment variable `DEBUG` is set, bash script will print debug
> information

Will print options. An example usage can be:

```
docker run --rm -it ghcr.io/mikroways/nexus-maven-download \
  -h https://nexus.example.com -r maven-repo -g com.example \
  -a myCustomArtifact -v 1.0.1 -u username -p supersecret
```

The image will download artifact into /tmp/artifact.jar. This allows you to
combine this image in a multi-stage Dockerfile:

```
FROM ghcr.io/mikroways/nexus-maven-download as artifact

ARG  NEXUS_HOST \
     NEXUS_REPO \
     NEXUS_GROUP \
     NEXUS_ARTIFACT \
     NEXUS_VERSION \
     NEXUS_USERNAME \
     NEXUS_PASSWORD

CMD [ "-h", $NEXUS_HOST, "-r", $NEXUS_REPO, "-g", $NEXUS_GROUP,
      "-a", $NEXUS_ARTIFACT, "-v", $NEXUS_VERSION,
      "-u", $NEXUS_USERNAME, "-p", $NEXUS_PASSWORD ]

FROM amazoncorretto:11-alpine
...
COPY --from=artifact /tmp/artifact.jar /app/App.jar
...
```
