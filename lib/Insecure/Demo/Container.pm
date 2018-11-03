package Insecure::Demo::Container;

use strictures 2;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(service);

use Bread::Board;
use Cpanel::JSON::XS;
use DBI;

my $services = container 'Services' => as {
    service BannedUsers => (
        class        => 'Insecure::Demo::Service::BannedUsers',
        dependencies => {
            dbh => '/Dependencies/DBConnection',
        },
    );
};

Bread::Board::set_root_container($services);

container 'Dependencies' => as {

    service DBConnection => (
        block => sub {
            my $s = shift;
            return DBI->connect(
                $s->param('connection_string'),
                $s->param('username'),
                $s->param('password'),
                {
                    RaiseError => 1,
                    AutoCommit => 1,
                    %{ $s->param('options') // {} }
                },
            );
        },
        dependencies => {
            connection_string => '/Config/dbconnection',
            username          => '/Config/dbconnection.username',
            password          => '/Config/dbconnection.password',
            options           => '/Config/dbconnection.options',
        },
        lifecycle => 'Singleton',
    );

};

my $config = container 'Config' => as {};

my %defaults = (
    dbconnection           => 'dbi:SQLite::memory:',
);

my %complex_keys = ( 'dbconnection.options' => 1, );

# Look for config in env or use the defaults above.
for my $key (
    qw/dbconnection dbconnection.username
    dbconnection.password dbconnection.options
    /
  )
{
    my $ekey = 'INSECURE_DEMO_' . uc( $key =~ s/\./_/gr );
    my $val = $ENV{$ekey} // $defaults{$key};
    if ( $complex_keys{$key} && exists $ENV{$ekey} ) {
        $val = json_decode($val);
    }
    $config->add_service( service $key => $val );
}

no Bread::Board;    # removes keywords

sub service {
    return $services->resolve( service => shift, @_ );
}

1;

