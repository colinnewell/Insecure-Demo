#!/usr/bin/env perl

use strict;
use warnings;

use CGI;
use HTML::Entities;
use Insecure::Demo::Container 'service';

run();

sub run {
    my $query = CGI->new;

    my $user_id = $query->param('user_id');

    unless ($user_id) {
        print $query->header( -status => 404 );
        print "Error: Missing User ID";
        return;
    }

    if ( $ENV{ID_ID} != $user_id && !$ENV{ID_ADMIN} ) {
        print $query->header( -status => 403 );
        print "Error: you are not allowed to edit this user";
        return;
    }

    my $user = service('Users')->user_details($user_id);

    unless ($user) {
        print $query->header( -status => 404 );
        print "Error: failed to find user";
        return;
    }

    if ( $query->param('updateuser') ) {
        update_user( $query, $user );
    }
    else {
        display_user( $query, $user );
    }
}

sub display_user {
    my ( $query, $user ) = @_;

    print $query->header();
    my $name    = encode_entities( $query->param('name') // $user->{ID_NAME} );
    my $user_id = $user->{ID_ID};
    my $saved_message = '';
    if ( $query->param('saved') ) {
        $saved_message = '<p>Saved</p>';
    }
    print <<"HTML";
<html>
<body>
    <h1>Edit User</h1>
    $saved_message
    <form method="POST">
        <label>Name<input type="text" name="name" value="$name"></label>
        <input type="hidden" name="user_id" value="$user_id">
        <input type="submit" name="updateuser" value="Save">
    </form>
</body>
</html>
HTML
}

sub update_user {
    my ( $query, $user ) = @_;
    service('Users')->edit_user(
        id    => $user->{ID_ID},
        admin => $user->{ID_ADMIN},
        name  => $query->param('name') || ''
    );

    print $query->redirect(
        -uri => $query->script_name . '?user_id=' . $user->{ID_ID} . '&saved=1',
        -status => '302 Moved Temporarily'
    );
}
