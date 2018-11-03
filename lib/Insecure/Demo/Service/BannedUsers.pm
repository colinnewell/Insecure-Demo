package Insecure::Demo::Service::BannedUsers;

use Moo;
use Params::Validate qw/validate SCALAR/;

has dbh => ( is => 'ro' );

sub is_client_banned {
    my $self = shift;
    my %args = validate @_,
      {
        client         => 0,
        email          => 0,
        referer        => 0,
        remote_address => 0,
      };
    if ( $args{client} ) {
        my $found = $self->dbh->selectrow_array(<<"SQL");
            SELECT count(*)
              FROM banned_clients
             WHERE client = '$args{client}'
SQL
        return $found if $found;
    }

    # TODO: check the rest of the tables too.

    return 0;
}

1;

