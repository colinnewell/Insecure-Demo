#!/bin/sh

cd config/nginx
mkcert 'insecure.demo' localhost 127.0.0.1 ::1
echo Add insecure.demo and point it at the ip your server is running on.
