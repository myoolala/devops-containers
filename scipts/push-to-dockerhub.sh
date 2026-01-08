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

    # Cuz my mac
    # docker build --platform linux/amd64 -f "dockerfiles/$1" -t $2-linux/amd64 $3 ./dockerfiles 
    # docker push 5pmgrass/tenviac:$2-linux/amd64
    echo "Building aarch64"
    docker build --platform linux/aarch64 -f "dockerfiles/$1" -t $2-linux-aarch64 $3 ./dockerfiles
    echo "pushing aarch64"
    docker tag $2-linux-aarch64 5pmgrass/tenviac:$2-linux-aarch64
    docker push 5pmgrass/tenviac:$2-linux-aarch64
    docker tag $2-linux-aarch64 5pmgrass/tenviac:$2
    docker push 5pmgrass/tenviac:$2
    docker tag $2-linux-aarch64 5pmgrass/tenviac:latest
    docker push 5pmgrass/tenviac:latest
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