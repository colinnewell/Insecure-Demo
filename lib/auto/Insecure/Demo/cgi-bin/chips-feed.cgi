#!/usr/bin/env perl

use strict;
use warnings;

use CGI;
use DateTime;
use Insecure::Demo::Container 'service';
use Try::Tiny;
use XML::LibXML;

run();

sub run {
    open( my $stdin, "<&STDIN" );
    my $query = CGI->new;

    binmode( *STDIN, ":utf8" );

    my $dom = try {
        XML::LibXML->load_xml( IO => $stdin );
    }
    catch {
        warn $_;
        return;
    };
    unless ($dom) {
        print $query->header( -status => 400 );
        print "Error: Failed to read XML request properly";
        return;
    }
    my $username = $dom->findvalue('//auth/username');
    my $password = $dom->findvalue('//auth/password');
    my $date     = $dom->findvalue('//query/date');

    # Use same error even for auth failure to prevent them learning anything.
    my $error = "No entries found for date $date";

    my $retval = service('Users')->user_valid( $username, $password );
    if ( $retval->{fail} ) {
        print $query->header( -status => 400 );
        print "Error: $error";
        return;
    }

    my $order_data = service('FishAndChips')->orders( date => $date, );

    unless (@$order_data) {
        print $query->header( -status => 400 );
        print "Error: $error";
    }

    # read the request body to grab xml for a starter
    # then emit xml

    print $query->header( -status => 200 );
    my $doc = XML::LibXML::Document->new( '1.0', 'UTF-8' );
    my $elem = $doc->createElement('orders');

    for my $order (@$order_data) {
        $elem->appendChild(_order_elem($doc, $order));
    }

    $doc->setDocumentElement($elem);

    $doc->toFH(*STDOUT);
}

sub _order_elem {
    my ($doc, $order) = @_;

    my $oe = $doc->createElement('order');
    _add_elem($doc, $oe, 'name', $order->{name});
    _add_elem($doc, $oe, 'id', $order->{id});
    _add_elem($doc, $oe, 'food', $order->{food});
    return $oe;
}

sub _add_elem {
    my ($doc, $element, $name, $value) = @_;

    my $child = $doc->createElement($name);
    $child->appendTextNode($value);
    $element->appendChild($child);
}

1;
