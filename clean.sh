#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD $WORKDIR
    rm -fr amq-* jboss-eap-* fuse-karaf-*
POPD

