#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
TARGET=${SCRIPT_DIR}/man

rm -rf "$TARGET"

yes | unminimize

apt-get update

apt-get install -y \
  man manpages-dev

mkdir -p "$TARGET"

cp -r /usr/share/man/man{1..8} "$TARGET"
