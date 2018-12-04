# Workstation Setup

In order to make use of this you'll need Docker and Docker Compose.

We're expecting Docker Engine version 17.06.0+ (run `docker --version`
to check).

[mkcert](https://github.com/FiloSottile/mkcert) is also a requirement to generate the ssl certificates.

## Download

First clone this repository.

    git clone https://github.com/colinnewell/Insecure-Demo.git
    cd Insecure-Demo

## Build

Make sure you've installed `mkcert` and run `mkcert -install`.

Run the `create_cert.sh` script to generate the ssl certificates for the
site to allow it to run from https://insecure.demo/

    ./create_cert.sh

This should create the files `insecure.demo+3.pem` and `insecure.demo+3-key.pem`
for nginx to use.

## Running

Now run the stack using docker-compose,

    docker-compose up -d

This should bring up the database server and the web server.

Now find the ip address of the web server using docker inspect,

    docker inspect --format '{{ range .NetworkSettings.Networks}}{{ .IPAddress }}{{end}}' `docker-compose ps -q nginx`
    192.168.112.3

And add this to your /etc/hosts file

    192.168.112.3   insecure.demo

Now browse to https://insecure.demo in your browser, or use curl to test it.
Note that with curl you will need to use the `--insecure` (`-k` for short) flag
because this is a self signed certificate.

Alternatively, if you're on Mac/Windows or some environment
where you can't access the local docker ip addresses, you can
expose the ports to the outside and access the site via https://localhost/.

Just remember this is an INSECURE website, which is why that's not
the default option.  Use this command to open up to the world (or at least
your local network),

    docker-compose -f docker-compose.yml -f docker-compose-open-insecure-webserver.yml up -d

## Updating to a new version

Note that the docker-compose environment mounts the current git repo and
runs the code from that, rather than the docker container out of the box.
This means that you ideally want to keep the git repo and docker containers
in sync.

    git pull
    docker-compose pull

If there are database changes you will need to re-create the database or
manually apply the database changes yourself.  See
[DEVELOPING.md](DEVELOPING.md#database-updates) for how to deal with database
updates.

## Static secrets

The application needs various secrets in order to run.  The CSRF tokens and
various login cookies all require these.  Out of the box the application will
generate these on startup.  This means that whenever the app is restarted
existing cookies will become invalid requiring re-logging in.

To avoid the secrets being regenerated every time the app starts there is a script
to provide those secrets via environment variables via a
docker-compose.override.yml.

Note that this script will require the Crypt::Sodium module to be installed
locally.  This will require the libsodium-dev package to be installed on debian
based distributions.

    bin/generate-config.pl

Now the docker-compose.override.yml is there when you should restart the environment
using

    docker-compose up -d

Now when you restart the application sessions and XSRF tokens won't be invalidated.

    docker-compose restart dancer

## Adding an Admin user

To add an admin user use the add-user.pl script.  Replace username/password and name
with the details you want.

    docker-compose run dancer perl -I /opt/insecure-demo/lib bin/add-user.pl "name" username password

Now you can log into to the admin part of the system.  Note that there is also
an admin flag that users can have.  To set that you'll need to do that manually using SQL
(see below for connecting to the database manually).

## Logs

To see the logs of the servers use docker-compose,

    docker-compose logs mysql
    docker-compose logs -f dancer # -f keeps watching the logs for new things

Or if you want to see all the logs don't specfiy a machine,

    docker-compose logs -f

## Connecting to the database

The root password for the database is generated when the server is
initially started.  You can find it in the logs.

    docker-compose logs mysql | grep GENERATED
    mysql_1   | [Entrypoint] GENERATED ROOT PASSWORD: ####################

Once you have the password you can log into mysql,

    docker-compose exec mysql mysql demo -p
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    mysql> show tables;
    +----------------+
    | Tables_in_demo |
    +----------------+
    | banned_clients |
    | fish_and_chips |
    | hidden         |
    +----------------+
    3 rows in set (0.00 sec)

