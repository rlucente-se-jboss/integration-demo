#!/usr/bin/env bash

. $(dirname $0)/demo.conf

PUSHD $WORKDIR
    echo

    if [ -d "$JBOSS_HOME" ]
    then
        echo "RHDM currently installed.  Please remove it before attempting install."
        echo
        exit 1
    fi

    echo -n "Install EAP ..................... "
    unzip -q $BINDIR/jboss-eap-$VER_DIST_EAP.zip
    ISOK

    if [ -n "$VER_PATCH_EAP" ]
    then
        echo -n "Patch EAP ....................... "
        $JBOSS_HOME/bin/jboss-cli.sh \
            --command="patch apply --override-all ${BINDIR}/jboss-eap-${VER_PATCH_EAP}-patch.zip" \
            &> /dev/null
        ISOK
    fi

    RHDM_DC_DEPLOY=rhdm-$VER_DIST_RHDM-decision-central-eap7-deployable

    echo -n "Install RHDM decision-central ... "
    unzip -qo $BINDIR/$RHDM_DC_DEPLOY.zip
    ISOK

    TMPDIR=tmp.$$
    mkdir -p $TMPDIR
    PUSHD $TMPDIR
        echo -n "Extract RHDM KIE server ......... "
        unzip -qo $BINDIR/rhdm-$VER_DIST_RHDM-kie-server-ee7.zip
        ISOK

        echo -n "Install KIE server war .......... "
        cp -fr kie-server.war $JBOSS_HOME/standalone/deployments
        touch $JBOSS_HOME/standalone/deployments/kie-server.war.dodeploy
        ISOK

        echo -n "Install security policy files ... "
        cp -f SecurityPolicy/* $JBOSS_HOME/bin
        ISOK
    POPD
    rm -fr $TMPDIR

    echo -n "Create KIE user ................. "
    $JBOSS_HOME/bin/add-user.sh -a -r ApplicationRealm -u "$KIE_USER" -p "$KIE_PASS" \
        -ro "$KIE_ROLES" --silent
    ISOK

    cat > sysprops.cli <<END1
embed-server --server-config=standalone.xml
/system-property=org.kie.server.user:add(value="$KIE_USER")
/system-property=org.kie.server.pwd:add(value="$KIE_PASS")
/system-property=org.kie.server.controller.user:add(value="$KIE_USER")
/system-property=org.kie.server.controller.pwd:add(value="$KIE_PASS")
/system-property=org.kie.server.id:add(value="default-kieserver")
/system-property=org.kie.server.location:add(value="http://localhost:8080/kie-server/services/rest/server")
/system-property=org.kie.server.controller:add(value="http://localhost:8080/decision-central/rest/controller")
stop-embedded-server
END1

    echo -n "Configure system properties ..... "
    $JBOSS_HOME/bin/jboss-cli.sh --file=sysprops.cli &> /dev/null
    ISOK
    rm -f sysprops.cli

    echo -n "Add PostgreSQL module ........... "
    $JBOSS_HOME/bin/jboss-cli.sh --command="module add --name=org.postgresql \
        --resources=$BINDIR/$PGJDBC --dependencies=javax.api,javax.transaction.api" \
        &> /dev/null
    ISOK

    cat > config-ds.cli <<END2
embed-server --server-config=standalone.xml
/subsystem=datasources/jdbc-driver=postgresql:add(driver-name=postgresql, driver-module-name=org.postgresql, driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource, driver-class-name=org.postgresql.Driver)
data-source add  --name=$PGJNDI --driver-name=postgresql \
    --jndi-name="java:jboss/datasources/$PGJNDI" \
    --connection-url="jdbc:postgresql://localhost:5432/$PGDBNAME" \
    --use-java-context=true --enabled=true \
    --user-name="$PGUSER" --password="$PGPASS" \
    --validate-on-match=true \
    --valid-connection-checker-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker \
    --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter
stop-embedded-server
END2

    echo -n "Add PostgreSQL datasource ....... "
    $JBOSS_HOME/bin/jboss-cli.sh --file=config-ds.cli &> /dev/null
    ISOK
    rm -f config-ds.cli

    echo -n "Setting admin password .......... "
    ${JBOSS_HOME}/bin/add-user.sh -p "${ADMIN_PASS}" -u "${ADMIN_USER}" --silent
    ISOK

    echo "Done."
    echo
POPD
