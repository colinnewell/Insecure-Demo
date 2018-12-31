# Workstation Setup

In order to make use of this you'll need Docker and Docker Compose.

We're expecting Docker Engine version 17.06.0+ (run `docker --version` 
to check).

## Download

First clone this repository.

    git clone https://github.com/colinnewell/Insecure-Demo.git
    cd Insecure-Demo

## Running

Now run the stack using docker-compose,

    docker-compose up -d

This should bring up the database server and the web server.

Now find the web address of the web server using docker inspect,

    docker inspect --format 'http://{{ range .NetworkSettings.Networks}}{{ .IPAddress }}{{end}}' `docker-compose ps -q nginx`
    http://192.168.112.3

Now browse to that address in your browser, or use curl to test it.

Alternatively, if you're on Mac/Windows or some environment
where you can't access the local docker ip addresses, you can
expose the ports to the outside and access the site via http://localhost/.

Just remember this is an INSECURE website, which is why that's not
the default option.  Use this command to open up to the world (or at least
your local network),

    docker-compose -f docker-compose.yml -f docker-compose-open-insecure-webserver.yml up -d

## Adding an Admin user

To add an admin user use the add-user.pl script.

    docker-compose run dancer perl -I /opt/insecure-demo/lib bin/add-user.pl "name" username password

## Logs

To see the logs of the servers use docker-compose,

    docker-compose logs mysql
    docker-compose logs -f dancer # -f keeps watching the logs for new things

## Changing the code

The source code in the repo is mounted into the container so
that you can experiment with modifying it.  If you do modify the code
you can restart the web server to test it's effect.

    docker-compose restart dancer

Note that template changes shouldn't require a restart.

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

