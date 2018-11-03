# Insecure Demo

A Demo platform for playing about with vulnerabilities.

This software is deliberately built insecure to allow the demonstration of
problems.

You can then fix them or exploit them.

## Running

    docker-compose up -d

## Debugging

## Building with a local CPAN.

For the travellers with flaky internet a local CPAN can be an amazing tool.
To make it simple to build the docker container with that it's possible to
inject an `EXTRA_CPANM` variable to pass cpanm extra command line parameters,
like a the mirror to use.

    sudo docker build . --build-arg "EXTRA_CPANM=-Mhttp://172.17.0.1:8090"

Note that if you are running a local cpan in docker then inter docker
communications may be disallowed so you may want to expose the port for
the cpan on the local machine to allow access.  This is certainly true
if running with docker-compose as it's likely to be on it's own network
which will be segmented away from the network the build is being run from.

See https://github.com/colinnewell/CPAN-Mirror-Docker for running a mirror
in docker locally.
