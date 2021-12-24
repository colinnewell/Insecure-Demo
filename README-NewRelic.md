# New Relic

To monitor the site using New Relic you can include the `docker-compose-nr.yml`
compose file.

    export NEWRELIC_LICENSE_KEY=xxxxxxxxxxxxxxxxx
    docker-compose -f docker-compose.yml -f docker-compose-nr.yml up -d

This will use the NewRelic C daemon to send data about the web transactions
across to New Relic.
