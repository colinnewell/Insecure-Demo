use Test2::V0;

use Crypt::Sodium;
use Insecure::Demo::Service::Users;

my $password_hash;
my $db = mock {}, add => [
    selectrow_array => sub {
        return ( 2, $password_hash, 0, 0 );
    },
];

my $users = Insecure::Demo::Service::Users->new(
    cookie_key => 'fake',
    dbh           => $db,
    login_secret  => crypto_stream_key(),
    password_cost => 10,
);
my $ret = $users->user_step('username1');
is $users->get_user( $ret->{auth_cookie} ), 'username1';

$password_hash = $users->_hash('password');
diag $password_hash;

$ret = $users->user_valid( 'testuser', 'password' );
is $ret->{next}, 'done';
my $user_id = $users->get_user_id( $ret->{token} );
is $user_id, 2;

done_testing;
