#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD $WORK_DIR
    ./fuse-karaf-$VER_DIST_FUSE/bin/fuse
POPD

