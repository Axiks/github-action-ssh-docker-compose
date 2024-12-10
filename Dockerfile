FROM alpine:3.8
RUN apk add --no-cache openssh bash git python3
ADD entrypoint.sh /entrypoint.sh
COPY tokenEncode.py /tokenEncode.py
COPY tokenEncode.py /github/workspace/tokenEncode.py
WORKDIR /github/workspace
ENTRYPOINT /bin/bash /entrypoint.sh
