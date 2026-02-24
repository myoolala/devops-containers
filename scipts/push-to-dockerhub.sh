#! /bin/bash
set -Eeuo pipefail

buildAndPush() {
    if [[ "$1" == "" ]]; then
        echo "Need a docker file to build"
        exit 1
    fi

    if [[ "$2" == "" ]]; then
        echo "Need a tag to use"
        exit 1
    fi

    docker buildx create --use --name multiarch-builder || docker buildx use multiarch-builder
    docker buildx inspect --bootstrap

    # Cuz my mac
    # echo "Building linux/amd64"
    docker buildx build --platform linux/amd64,linux/aarch64 -f "dockerfiles/$1" \
        -t 5pmgrass/tenviac:$2 \
        -t 5pmgrass/tenviac:latest \
        $3 ./dockerfiles --push
}

cd ../

if [[ "$1" == "" ]]; then
    echo "Need a tag version to use"
    exit 1
fi

if [[ "$2" == "" ]]; then
    echo "Need a tenv version to use"
    exit 1
fi

buildAndPush "golang-base.Dockerfile" "golang-$1" "--build-arg TENV_VERSION=v$2"
buildAndPush "golang-base.Dockerfile" "$1" "--build-arg TENV_VERSION=v$2"