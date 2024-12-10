FROM alpine:3.8
RUN apk add --no-cache openssh bash git python3
ADD entrypoint.sh /entrypoint.sh
ADD tokenEncode.py /tokenEncode.py
WORKDIR /github/workspace
ENTRYPOINT /bin/bash /entrypoint.sh
