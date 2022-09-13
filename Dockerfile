FROM debian:bullseye-slim as builder
RUN mkdir -p /scripts
COPY builder-scripts/*.sh /scripts/
RUN apt-get update && apt-get install -y \
    git \
    libp8-platform-dev \
    libssl-dev \
    libudev-dev \
    curl \
    cmake \
    python3-dev \
    qtbase5-dev \
    libqt5serialport5-dev \
    libqt5sql5-sqlite \
    libqt5svg5-dev \
    libqt5x11extras5-dev \
    libusb-1.0-0-dev \
    libcec-dev \
    libavahi-core-dev \
    libavahi-compat-libdnssd-dev \
    libxcb-util0-dev \
    libxcb-randr0-dev \
    libxcb-shm0-dev \
    libxcb-render0-dev \
    libxcb-image0-dev \
    libxrandr-dev \
    libxrender-dev \
    libturbojpeg0-dev \
    build-essential \
    devscripts \
    fakeroot \
    libdistro-info-perl \
    libmbedtls-dev \
    zlib1g-dev \
    && /scripts/install-deps.sh \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /source
COPY source /source

ARG BUILD_TYPE="Release"
ARG BUILD_ARGS=""
ARG CORECOUNT="1"
RUN uname -m > /tmp/build_arch
ENV BUILD_TYPE="${BUILD_TYPE}"
ENV BUILD_ARGS="${BUILD_ARGS}"

RUN mkdir -p /source/build/ && mkdir -p /opt/
WORKDIR /source/build
RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  BUILD_ARCH=amd64  ;; \
         "linux/arm64")  BUILD_ARCH=arm64  ;; \
         "linux/arm/v7") BUILD_ARCH=armv7l  ;; \
         "linux/arm/v6") BUILD_ARCH=armv6l  ;; \
    esac \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt -maxcpucount -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DPLATFORM=${BUILD_ARCH} ${BUILD_ARGS} /source
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