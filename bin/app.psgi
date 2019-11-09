#!/usr/bin/env perl

# PODNAME: app.psgi

use strict;
use warnings;

use CGI::Compile;
use CGI::Emulate::PSGI;
use File::ShareDir 'module_dir';
use Insecure::Demo;
use Insecure::Demo::Admin;
use Insecure::Demo::Admin::Config;
use Insecure::Demo::Admin::Login;
use Path::Tiny;
use Plack::Builder;

my $secret_key = $ENV{INSECURE_DEMO_SECRET};
unless ($secret_key) {
    open my $rand, '<', '/dev/urandom' or die 'Failed to open /dev/urandom';
    my $bytes = '0' x 32;
    die "Failed to read sufficient from random - $!"
      unless sysread( $rand, $bytes, 32 ) == 32;
    close $rand;
    $secret_key = unpack 'H*', $bytes;
}

my $cgi_dir = path( module_dir('Insecure::Demo') )->child('cgi-bin')->stringify;
my $cgi     = Plack::Builder->new;

builder {
    enable 'Session::Cookie',
      session_key => 'insecure-demo',
      expires     => 12 * 3600,         # 12 hour
      secure      => 1,
      httponly    => 1,
      secret      => $secret_key;

    # avoid turning on XSRF detection for the XML API routes
    enable_if { shift->{CONTENT_TYPE} ne 'text/xml' } 'CSRFBlock';

    mount '/admin/login' => Insecure::Demo::Admin::Login->to_app;
    mount '/admin'       => builder {
        enable '+Insecure::Demo::Middleware::Admin';
        for (<$cgi_dir/admin/*.cgi>) {
            my $sub  = CGI::Compile->compile($_);
            my $app  = CGI::Emulate::PSGI->handler($sub);
            my $path = '/cgi-bin/' . $_ =~ s|^.*/admin/||r;
            mount $path, $app;
        }
        mount '/config' => Insecure::Demo::Admin::Config->to_app;
        mount '/'       => Insecure::Demo::Admin->to_app;
    };
    for (<$cgi_dir/*.cgi>) {
        my $sub  = CGI::Compile->compile($_);
        my $app  = CGI::Emulate::PSGI->handler($sub);
        my $path = '/cgi-bin/' . path($_)->basename;
        mount $path, $app;
    }
    mount '/' => Insecure::Demo->to_app;
}

