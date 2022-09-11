ARG BUILD_ARCH="x86_64"
ARG BUILDER_TAG="bullseye"
ARG BUILDER_REGISTRY="ghcr.io/hyperion-project"
FROM ${BUILDER_REGISTRY}/${BUILD_ARCH}:${BUILDER_TAG} as builder
ARG BUILDER_TAG="bullseye"
ENV BUILDER_TAG="${BUILDER_TAG}"
RUN apt-get update && apt-get install -y curl
RUN curl http://archive.raspberrypi.org/debian/raspberrypi.gpg.key --output raspi.gpg.key && apt-key add raspi.gpg.key
RUN echo "deb http://archive.raspberrypi.org/debian/ ${BUILDER_TAG} main" > /etc/apt/sources.list.d/raspi.list
RUN apt-get update && apt-get install -y \
    git \
    libraspberrypi-dev \
    libcec-dev \
    libp8-platform-dev \
    libudev-dev

WORKDIR /source
COPY source /source

ARG BUILD_ARCH="x86_64"
ARG BUILD_TYPE="Release"
ARG BUILD_ARGS=""
ARG CORECOUNT="1"
ENV BUILD_ARCH="${BUILD_ARCH}"
ENV PLATFORM="-DPLATFORM=${BUILD_ARCH}"
ENV BUILD_TYPE="${BUILD_TYPE}"
ENV BUILD_ARGS="${BUILD_ARGS}"

RUN mkdir -p /source/build/ && mkdir -p /opt/
WORKDIR /source/build
# RUN printenv && echo ${PLATFORM}
RUN cmake -DCMAKE_INSTALL_PREFIX=/opt -maxcpucount -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ${PLATFORM} ${BUILD_ARGS} /source
RUN make -j ${CORECOUNT} package
RUN make install/strip

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    libusb-1.0.0 \
    libexpat1 \
    libgl1 \
    libglib2.0-0 \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/opt/"
ENV PYTHONHOME=/usr/local

COPY --from=builder /opt /opt
WORKDIR /hyperion

EXPOSE 8090 8092 19400 19445 19444 19333
VOLUME /hyperion
ENTRYPOINT ["/opt/bin/hyperiond", "--userdata", "/hyperion"]