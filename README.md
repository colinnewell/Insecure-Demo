# Insecure Demo

This is archived as it's no longer under development and updating the deps to
avoid security problems isn't worth it for me.  Feel free to clone the repo if
you want to do something with it.

A Demo platform for playing about with vulnerabilities.

This software is deliberately built insecure to allow the demonstration of
problems.

You can then fix them or exploit them.

## Running

To run on your machine run with docker compose like this:

    docker-compose up -d

This will mount the source directory so that you can run the latest code.

Note that you need to create SSL certificates to make use of the nginx,
see instructions in [WORKSTATION-SETUP.md](WORKSTATION-SETUP.md).

## More information.

See [WORKSTATION-SETUP.md](WORKSTATION-SETUP.md) for getting a handle on running
the site on your machine, and [DEVELOPING.md](DEVELOPING.md) for notes on
development and debugging.

The [SCENARIOS.md](SCENARIOS.md) file contains ideas for things to do with
this site.

If you want more information on the security problems presented on this site
take a look at [READING-LIST.md](READING-LIST.md).
