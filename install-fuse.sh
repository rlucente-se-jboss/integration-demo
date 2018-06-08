#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD ${WORKDIR}
    echo
    if [ -d "fuse-karaf-$VER_DIST_FUSE" ]
    then
        echo "Fuse currently installed.  Please remove it before attempting install."
        echo
        exit 1
    fi

    echo -n "Installing Fuse ......... "
    unzip -q ${BINDIR}/fuse-karaf-${VER_DIST_FUSE}.zip
    ISOK

    PUSHD fuse-karaf-${VER_DIST_FUSE}/etc
        echo -n "Configuring Fuse user ... "
        cat >> users.properties <<EOF
${FUSE_USER} = ${FUSE_PASS},_g_:${FUSE_GROUP}
_g_\:${FUSE_GROUP} = ${FUSE_ROLES}
EOF
        ISOK
    POPD
    echo "Done."
    echo
POPD

