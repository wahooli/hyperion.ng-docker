#!/bin/bash
DEST_REPO="wahooli/hyperion.ng"
DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}
REPO_URL="https://github.com/hyperion-project/hyperion.ng.git"
SCRIPT=$(realpath "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

USE_BUILDX=${USE_BUILDX:-0}
BUILDX_PLATFORMS=${BUILDX_PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6}
BUILDX_CONTEXT=${BUILDX_CONTEXT:-mycrossbuild}

# defaults to your cpu arch
CPU_ARCH=${CPU_ARCH:-$(uname -m)}
# defaults to latest hyperion.ng release/tag
RELEASE=${RELEASE:-$(curl -sL https://api.github.com/repos/hyperion-project/hyperion.ng/releases/latest | jq -r ".tag_name")}
DEST_TAG=${DEST_TAG:-$RELEASE}
CLONE_PATH="${SCRIPT_PATH}/source"

if [ ! -d "$CLONE_PATH" ]; then
    mkdir -p $CLONE_PATH
    cd $CLONE_PATH
    git init 
    git remote add origin $REPO_URL
fi

cd $CLONE_PATH
git fetch --tags
git checkout $RELEASE
git submodule update --init --recursive

if [[ "$OSTYPE" == "cygwin" ]]; then
    SCRIPT_PATH=$(cygpath -w "${SCRIPT_PATH}")
fi

if [[ "$USE_BUILDX" == "1" ]]; then
    docker buildx create --use --name $BUILDX_CONTEXT
    docker buildx build --progress=plain --platform ${BUILDX_PLATFORMS} ${SCRIPT_PATH} --build-arg BUILD_ARCH=${CPU_ARCH} --build-arg CORECOUNT=$(nproc) --push --tag ${DEST_REPO}:${DEST_TAG}
else
    docker build ${SCRIPT_PATH} --build-arg BUILD_ARCH=${CPU_ARCH} --build-arg CORECOUNT=$(nproc) -t ${DEST_REPO}:${DEST_TAG}
fi
