package Insecure::Demo::Form::Password;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+is_html5' => ( is => 'ro', default => 1 );

has_field username => ( type => 'NonEditable',    required => 1 );
has_field password => ( type => 'Password', required => 1 );
has_field next     => ( type => 'Submit',   value    => 'Next' );

1;

