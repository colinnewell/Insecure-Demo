#!/usr/bin/env perl
use strictures 2;
use Insecure::Demo::Container 'service';

service('Users')->add_user(shift, shift);
