package Insecure::Demo::Form::User;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+is_html5' => ( is => 'ro', default => 1 );

has_field username => ( type => 'Text',   required => 1 );
has_field next     => ( type => 'Submit', value    => 'Next' );

1;
