#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Insecure::Demo;

Insecure::Demo->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    Insecure::Demo->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Insecure::Demo;
use Plack::Builder;

builder {
    enable 'Deflater';
    Insecure::Demo->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Insecure::Demo;
use Insecure::Demo_admin;

builder {
    mount '/'      => Insecure::Demo->to_app;
    mount '/admin'      => Insecure::Demo_admin->to_app;
}

=end comment

=cut

