FROM alpine:3.8
RUN apk add --no-cache openssh bash git
ADD entrypoint.sh /entrypoint.sh
WORKDIR /github/workspace
ENTRYPOINT /bin/bash /entrypoint.sh
