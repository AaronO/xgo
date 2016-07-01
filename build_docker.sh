#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

# Compute repo's dir
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

IMAGE_PREFIX="karalabe/xgo"

function build_image() {
    local folder=$1
    local name=$2
    local version=$3

    bash -c "cd ${folder} && docker build -t ${name}:${version} ."
}

function get_version() {
    cat "${DIR}/VERSION"
}

# subdirs returns a list of directories in a folder
function subdirs() {
    local folder=$1
    bash -c "cd ${folder} && ls -d */" | sed 's/\/$//'
}

function main() {
    # Get ver
    local version=$(get_version)

    echo "Building base"
    build_image "${DIR}/docker/base" "${IMAGE_PREFIX}-base" "${version}"

    for goVersion in $(subdirs "${DIR}/docker" | grep -v base | sed 's/^go-//'); do
        echo
        echo "Building ${goVersion}"
        build_image "${DIR}/go-${goVersion}" "${IMAGE_PREFIX}-${goVersion}" "${version}"
    done
}

# Run main
main