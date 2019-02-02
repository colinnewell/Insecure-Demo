# Developing

## Changing the code

The source code in the repo is mounted into the container so
that you can experiment with modifying it.  If you do modify the code
you can restart the web server to test it's effect.

    docker-compose restart dancer

Note that template changes shouldn't require a restart.

See the note about [Static secrets](WORKSTATION-SETUP.md#static-secrets) for
a note on why restarting the app out of the box invalidates existing logins
and CSRF tokens.

## Database updates

There isn't a good database upgrade story yet as this project is developed.
For now the simple option is to remove the database and have it re-created.
To do this follow these steps,

    docker-compose down      # stops and deletes all the containers
    sudo rm -rf mysql-data/  # removes the mysql data folder
    docker-compose up -d     # mysql will be reinitialised.

## Debugging


## Environment variables

While debugging problems it might be handy to set environment variables.

Particular favourites while developing SQLi are `DBI_TRACE` and `DBIC_TRACE`.

These can be set easily in the `docker-compose.yml` or in a
`docker-compose.override.yml`* file.

    version: "3.3"
    services:
    dancer:
        environment:
            DBI_TRACE: "2|SQL"
            DBIC_TRACE: 1

Once you have setup the docker-compose file you then need to re-up the
environment so that the containers a re-created to contain the new
variables.

[*] The advantage of the `override` file is that it won't interfere with git.

## Building the container

Because the docker environment is provided on quay.io you can often get by
without needing to do any perl environment building yourself.

If you want to build the docker container yourself you can do that simply
enough.

    docker build . -t quay.io/colinnewell/insecure-demo

### Building with a local CPAN.

For the travellers with flaky internet a local CPAN can be an amazing tool.
To make it simple to build the docker container with that it's possible to
inject an `EXTRA_CPANM` variable to pass cpanm extra command line parameters,
like a the mirror to use.

    docker build . --build-arg "EXTRA_CPANM=-Mhttp://172.17.0.1:8090" \
            -t quay.io/colinnewell/insecure-demo

Note that if you are running a local cpan in docker then inter docker
communications may be disallowed so you may want to expose the port for
the cpan on the local machine to allow access.  This is certainly true
if running with docker-compose as it's likely to be on it's own network
which will be segmented away from the network the build is being run from.

See https://github.com/colinnewell/CPAN-Mirror-Docker for running a mirror
in docker locally.

