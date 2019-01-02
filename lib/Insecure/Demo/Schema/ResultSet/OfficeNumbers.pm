package Insecure::Demo::Schema::ResultSet::OfficeNumbers;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub office_lookup {
    my ( $self, $phone_number ) = @_;

    return $self->search(
        { "'$phone_number'" => { -like => \'concat("%", number_prefix, "%")' } }
    );
}

1;
