#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD ${WORKDIR}
    echo
    if [ -d "amq-broker-$VER_DIST_AMQ" ]
    then
        echo "AMQ currently installed.  Please remove it before attempting install."
        echo
        exit 1
    fi

    echo -n "Installing AMQ .... "
    unzip -qo ${BINDIR}/amq-broker-${VER_DIST_AMQ}-bin.zip
    ISOK

    echo -n "Creating broker ... "
    amq-broker-${VER_DIST_AMQ}/bin/artemis create \
        --allow-anonymous --nio --password "$AMQ_PASS" \
        --role "$AMQ_ROLE" --silent --user "$AMQ_USER" \
        amq-demo &> /dev/null
    ISOK

    echo "Done."
    echo
POPD

