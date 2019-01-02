package Insecure::Demo::Schema::Result::OfficeNumbers;

use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'int',
    is_auto_increment => 1,
};

column name => {
    data_type   => 'varchar',
    size        => 128,
    is_nullable => 1,
};

column number_prefix => {
    data_type   => 'varchar',
    size        => 128,
    is_nullable => 1,
};

column main_number => {
    data_type   => 'varchar',
    size        => 128,
    is_nullable => 1,
};


1;
