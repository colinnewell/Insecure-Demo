package Insecure::Demo::Service::TimeLogging;

use Moo;
use Params::Validate qw/validate/;
use SQL::Abstract::More;

use experimental 'signatures';

has dbh => ( is => 'ro' );

sub entries ( $self, $user ) {
    return $self->dbh->selectall_arrayref(
        <<~ 'SQL', { Slice => {} }, ($user) x 2 );
        SELECT t.code, t.title, s.seconds, u.name, u.username
          FROM time_spent s
    INNER JOIN users u ON s.user_id = u.id
    INNER JOIN tickets t ON t.id = s.ticket_id
         WHERE ? IS NULL OR s.user_id = ?
    SQL
}

sub create ( $self, %args ) {
    $self->dbh->do( <<~SQL, undef, @args{qw/user_id ticket_id seconds/} );
        INSERT INTO time_spent (user_id, ticket_id, seconds)
        VALUES (?, ?, ?);
    SQL
}

sub create_ticket ( $self, %args ) {
    $self->dbh->do( <<~SQL, undef, @args{qw/code title/} );
        INSERT INTO tickets (code, title)
        VALUES (?, ?);
    SQL
    my ($id) = $self->dbh->selectrow_array('SELECT LAST_INSERT_ID()');
    return $id;
}

sub search_tickets ( $self, %args ) {
    return $self->dbh->selectall_arrayref(
        <<~ 'SQL', { Slice => {} }, ( '%' . $args{term} . '%' ) );
        SELECT id, concat(code, ' ', title) AS value
          FROM tickets
         WHERE code LIKE ?
    SQL
}

1;
