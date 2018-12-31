#!/usr/bin/env perl
use strictures 2;

use Crypt::Sodium;

my $secret = unpack 'H*', randombytes_buf(32);
my $loginsecret = unpack 'H*', crypto_stream_key();
my $cookiekey = unpack 'H*', crypto_stream_key();

my $yaml = << "YAML";
version: "3.3"
services:
    dancer:
        environment:
            INSECURE_DEMO_SECRET: $secret
            INSECURE_DEMO_LOGINSECRET: $loginsecret
            INSECURE_DEMO_COOKIEKEY: $cookiekey
YAML

my $filename = 'docker-compose.override.yml';
open my $fh, '>', $filename or die "Unable to write to $filename - $!";;
print $fh $yaml;
close $fh;
