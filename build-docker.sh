#!/bin/bash
REPO_URL="https://github.com/hyperion-project/hyperion.ng.git"
SCRIPT=$(realpath "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

# defaults to your cpu arch
CPU_ARCH=${CPU_ARCH:-$(uname -m)}
# defaults to latest hyperion.ng release/tag
RELEASE=${RELEASE:-$(curl -sL https://api.github.com/repos/hyperion-project/hyperion.ng/releases/latest | jq -r ".tag_name")}

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
DOCKER_BUILDKIT=1 docker build ${SCRIPT_PATH} --build-arg BUILD_ARCH=${CPU_ARCH} --build-arg CORECOUNT=$(nproc) -t wahooli/hyperion.ng:${RELEASE}