#!/usr/bin/env bash
BUILDER_TAG="${BUILDER_TAG:-bullseye}"
curl http://archive.raspberrypi.org/debian/raspberrypi.gpg.key --output raspi.gpg.key && apt-key add raspi.gpg.key
echo "deb http://archive.raspberrypi.org/debian/ ${BUILDER_TAG} main" > /etc/apt/sources.list.d/raspi.list
if [ "$(uname -m)" != "x86_64" ]; then
    apt-get install libraspberrypi-dev
fi
rm raspi.gpg.key