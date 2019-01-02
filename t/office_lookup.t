use Test2::V0;
use Test::DBIx::Class {
    traits       => ['Testmysqld'],
    schema_class => 'Insecure::Demo::Schema',
  },
  'OfficeNumbers';

ok my $num = OfficeNumbers->create(
    {
        name          => 'London',
        number_prefix => '01',
        main_number   => '013321221',
    }
);
ok my $lookup = OfficeNumbers->office_lookup('01321321')->first;
is $lookup->name, 'London';

done_testing;
