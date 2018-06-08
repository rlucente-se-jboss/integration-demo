#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD $WORKDIR
    rm -fr jboss-eap-$VER_INST_EAP fuse-karaf-${VER_DIST_FUSE}
POPD

