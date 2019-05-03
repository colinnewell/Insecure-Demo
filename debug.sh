#!/bin/sh

FILES="-f docker-compose.yml -f docker-compose-debug.yml"
docker-compose $FILES up -d
docker attach $(docker-compose $FILES ps -q dancer )
