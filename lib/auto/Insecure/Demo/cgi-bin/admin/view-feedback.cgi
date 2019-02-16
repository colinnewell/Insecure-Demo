#!/usr/bin/env perl

use strict;
use warnings;

use Insecure::Demo::Container 'service';
use Template;

run();

sub run {
    my $query = CGI->new;

    unless ( $ENV{ID_ADMIN} ) {
        print $query->header( -status => 403 );
        print "Error: Admin access only";
        return;
    }

    my $template =
      Template->new( INCLUDE_PATH => '/opt/insecure-demo/templates' );
    print $query->header();
    $template->process(
        'view-feedback.tt',
        {
            feedback => service('Feedback')->feedback_list,
        }
    ) or die $template->error();
}
