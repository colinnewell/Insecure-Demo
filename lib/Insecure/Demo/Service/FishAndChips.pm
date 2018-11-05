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
        -columns  => [ 'name', 'food', 'added' ],
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

1;
