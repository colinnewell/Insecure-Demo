#!/usr/bin/env perl

# PODNAME: add-user.pl

use strictures 2;
use Insecure::Demo::Container 'service';

service('Users')->add_user(@ARGV);
