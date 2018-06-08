# Integration Demo
This is a simple integration demo where a camel route processes
orders and uses RHDM kieserver as a RESTful service to assign
geographic regions to each order.  The orders are placed into
dynamically created folders by region.  The RHDM project contains
a guided decision table where each country code is mapped to a
region and a simple POJO to represent the country code and region.

The camel route is based on the Fuse Quickstart camel-eips.

## Install and Run RHDM and Fuse
### Get the Binaries
The `dist/readme.txt` file contains the list of binaries needed for
this demo.  Please go to the [Red Hat customer service portal](https://access.redhat.com/) and
download the binaries to the `dist` directory.

### Check the Configuration
Please review the `demo.conf` configuration file.  If you change
any of the variables for the distribution versions, make sure that
they match the binaries in the `dist` folder.

### Start Fuse
In a separate terminal window, install and start Fuse using the commands:

    ./install-fuse.sh
    ./start-fuse.sh

### Start RHDM
In a separate terminal window, install and start RHDM using the commands:

    ./install-rhdm.sh
    ./start-rhdm.sh

## Run the Demo
### Build the Camel Bundle
In a separate terminal window, build the camel route using the
commands:

    git clone https://github.com/rlucente-se-jboss/fuse-amq-dm-demo.git
    cd fuse-amq-dm-demo
    mvn clean install

### Install Camel Bundle on Fuse
In the terminal window with the Fuse console (where you started
Fuse), type the following commands:

    features:install camel-http4
    bundle:install -s mvn:com.redhat/fuse-amq-dm-demo/1.0.0-SNAPSHOT

### Build and Deploy the KIE Jar
Browse to the decision-central web application at
http://localhost:8080/decision-central and login using the default
credentials `dmUser/admin1jboss!` defined in the file `demo.conf`
at install.  If you modified the credentials in `demo.conf`, then
use those.

Once logged in, from the top of the main page select `Menu -> Design
-> Projects`.  Press the `Import Project` button in the center of
the page and use the URL https://github.com/rlucente-se-jboss/myrepo.git
for the predefined RHDM project.  Press the `Import` button.  On
the `Import Projects` page, select the `RHDM Demo` project and press
the `Ok` button on the far right.

The RHDM Demo project will appear with two items:  a guided decision
table and a single data object.  Feel free to explore these.  When
done, press the `Build & Deploy` button on the right.  If you see
a `Conflicting Repositories` pop-up, just click the `Override`
button.

Select `Menu -> Deploy -> Execution Servers` at the top of the page.
You should see the `demo_1.0.0` KIE container deployed with a green
check mark.  If that's the case, everything is ready to go on the
KIE server.

### Send the Orders
From the terminal window where you built the camel route, copy the
file `src/main/fuse/data/orders.xml` to your fuse installation.
The command will resemble:

    cp src/main/fuse/data/orders.xml /path/to/fuse-karaf-7.0.0.fuse-000191-redhat-1/work/eip/input/

In the terminal window with the Fuse console, simply type:

    log:display

to see log messages of the orders being processed.  Each order has
a geographic region assigned via the REST interface to the guided
decision table on the KIE server.  The orders are also archived at
`work/eip/archives` and they are sorted by geographic region at
`work/eip/output`.

### Hawtio Console You can also browse to http://localhost:8181/hawtio
and then select `Camel` on the left hand side to see the live metrics
for the route as the messages were processed.

## Shutdown and Clean Up
Simply `CTRL-C` in the window where you started RHDM.  For Fuse,
type `shutdown` in the console.  To reset everything, run the
command:

    ./clean.sh

