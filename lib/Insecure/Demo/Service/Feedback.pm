package Insecure::Demo::Service::Feedback;

use Moo;
use Params::Validate qw/validate/;

has dbh => ( is => 'ro' );

sub store_feedback {
    my $self = shift;
    my %args = validate @_,
      {
        ip       => 1,
        name     => 1,
        comments => 1,
      };

    $self->dbh->do( <<'SQL', undef, @args{qw/ip name comments/} );
        INSERT INTO feedback (ip, name, comments)
             VALUES (?, ?, ?)
SQL
}

sub feedback_list {
    my ($self) = @_;

    return $self->dbh->selectall_arrayref( <<'SQL', { Slice => {} } );
        SELECT name, ip, created, comments
          FROM feedback
      ORDER BY id DESC
         LIMIT 20
SQL
}

1;
