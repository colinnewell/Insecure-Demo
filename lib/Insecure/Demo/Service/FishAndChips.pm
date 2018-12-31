package Insecure::Demo::Service::FishAndChips;

use Moo;
use Params::Validate qw/validate/;
use SQL::Abstract::More;

has dbh => ( is => 'ro' );

sub orders {
    my $self = shift;
    my %args = validate @_,
      {
        date     => 0,
        limit    => 0,
        offset   => 0,
        order_by => 0,
      };

    my $sqla = SQL::Abstract::More->new;
    my ( $sql, @bind ) = $sqla->select(
        -columns  => [ 'id', 'name', 'food', 'added' ],
        -from     => ['fish_and_chips'],
        -order_by => [ $args{order_by} || 'id' ],
        -where    => {
            added => {
                between =>
                  [ $args{date} . ' 00:00:00', $args{date} . ' 23:59:59' ]
            },
        },
        -offset => $args{offset} || 0,
        -limit  => $args{limit}  || 10,
    );
    my $outer_sql = sprintf( "SELECT * FROM (%s) orders", $sql );
    return $self->dbh->selectall_arrayref( $outer_sql, { Slice => {} }, @bind );
}

sub add_order {
    my $self = shift;
    my %args = validate @_,
      {
        name => 1,
        food => 1,
      };

    my $name = $self->dbh->quote( $args{name} );
    my $food = $self->dbh->quote( $args{food} );
    $self->dbh->do(
        "INSERT INTO fish_and_chips
                     (name, food, added)
              VALUES ($name, $food, UTC_TIMESTAMP())"
    );
}

sub edit_order {
    my ( $self, %args ) = @_;

    $self->dbh->do(
        'UPDATE fish_and_chips
            SET name = ?,
                food = ?
          WHERE id = ?;', undef, $args{name}, $args{food}, $args{id}
    );
}

1;
