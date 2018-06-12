#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD $WORK_DIR
    ./amq-demo/bin/artemis run
POPD

