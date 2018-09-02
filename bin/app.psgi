#!/usr/bin/env perl

# PODNAME: app.psgi

use strict;
use warnings;

use Plack::Builder;
use Insecure::Demo;

my $secret_key = $ENV{INSECURE_DEMO_SECRET};
unless ($secret_key) {
    open my $rand, '<', '/dev/urandom' or die 'Failed to open /dev/urandom';
    my $bytes = '0' x 32;
    die "Failed to read sufficient from random - $!"
      unless sysread( $rand, $bytes, 32 ) == 32;
    close $rand;
    $secret_key = unpack 'H*', $bytes;
}

builder {
    enable 'Session::Cookie',
      session_key => 'insecure-demo',
      expires     => 12 * 3600,         # 12 hour
      secret      => $secret_key;
    enable 'CSRFBlock';

    Insecure::Demo->to_app;
}

