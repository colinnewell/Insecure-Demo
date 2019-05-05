use Test2::V0;
use Test2::Plugin::NoWarnings;

use HTTP::Request::Common;
use Insecure::Demo::Admin::Login;
use Insecure::Demo::Service::Users;
use Plack::Test;

my $valid_key_handle =
'4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s4';
my $valid_user_key = pack 'H*',
'045855059149d36a6e8161fe7f2d49fe19168b598889dc076a80892aa4fafa86e9830e3844a0428d5e257ce53594c6226dc10f44d25427fd99db547664564ee961';
my $fake_but_plausible_key_handle =
'4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s3';
my $fake_but_plausible_user_key = pack 'H*',
'045855059149d36a6e8161fe7f2d49fe19168b598889dc076a80892aa4fafa86e9830e3844a0428d5e257ce53594c6226dc10f44d25427fd99db547664564ee962';
my $evilsite_handle =
'hUYC_FIPUydNLLUGc-wT8KZhXhvoGPtWMXcqS8i5ND5v8pnlkp0uWrHbzX9TqlYhMhm-KYXzSkHcazOOvxGmb-MK6-zwwb4tfgycfVvc8i9FlR2taydeFPlwJ_vkZgbj';
my $evilsite_user_key = pack 'H*',
'042FC3AA277472C384C2A37B445EC2B9034F0DC2A7C39452C3B2043223265AC28FC2B00D5AC3B0C2ABE2809D1529C386C3BC18C3BE6009C3A33AC3AD2717C2B951C2BF55215216C2A4210F74C3BA3221C3B2C3B2C385C3AEC3A03BE282AC';

my $test = Plack::Test->create( Insecure::Demo::Admin::Login->to_app );

subtest 'Happy path' => sub {
    my $mock = setup_mock(
        keys => [
            {
                key_handle => $valid_key_handle,
                user_key   => $valid_user_key,
            },
            {
                key_handle => $fake_but_plausible_key_handle,
                user_key   => $fake_but_plausible_user_key,
            },
        ]
    );

    my $response =
      $test->request( GET '/u2f', Cookie => 'userid=1; login=foo', );
    like $response->content, qr'keyHandle.*keyHandle';

    $response = $test->request(
        POST '/u2f',
        Cookie  => 'userid=1; login=foo',
        Content => [
            challenge => 'Yz3UYQfqmaEiczxqkYX8gi31n99-bqQZ_nRLLwsL9GM',
            'u2f_data' =>
'{"keyHandle":"4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s4","clientData":"eyJjaGFsbGVuZ2UiOiJZejNVWVFmcW1hRWljenhxa1lYOGdpMzFuOTktYnFRWl9uUkxMd3NMOUdNIiwibmV3X2tleXNfbWF5X2JlX2FkZGVkX2hlcmUiOiJkbyBub3QgY29tcGFyZSBjbGllbnREYXRhSlNPTiBhZ2FpbnN0IGEgdGVtcGxhdGUuIFNlZSBodHRwczovL2dvby5nbC95YWJQZXgiLCJvcmlnaW4iOiJodHRwczovL2luc2VjdXJlLmRlbW8iLCJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIn0","signatureData":"AQAAAAIwRQIgRwQ2BELLkX9MFJtcAKlIFcZ2paFipj97DUCeVefACPgCIQDtZFMfNUMXokEMDozM2Kls3o3OhTP9J1h67iR5-2nYPw"}',
        ]
    );
    is $response->header('location'), 'http://localhost/admin';
    ok grep { /user=/ } $response->headers->header('set-cookie'),
      'user cookie should be set';
};

# these tests aren't the greatest.  Trying to come up with 'realistic'
# attack scenarios and prove that they trigger the correct response is
# tricky.  Mostly the underlying u2f library is the thing that that does
# all the hard work and validates that everything is above board.  We're
# mostly trying to ensure we don't fail insecure, and that allowing
# the attacker to control the data they can control doesn't allow them
# to authenticate in situations they ought not to be able to.

subtest 'Valid challenge, not a key we have' => sub {
    my $mock = setup_mock(
        keys => [
            {
                key_handle => $fake_but_plausible_key_handle,
                user_key   => $fake_but_plausible_user_key,
            },
        ]
    );

    my $response;
    is warnings {
        $response = $test->request(
            POST '/u2f',
            Cookie  => 'userid=1; login=foo',
            Content => [
                challenge => 'Yz3UYQfqmaEiczxqkYX8gi31n99-bqQZ_nRLLwsL9GM',
                'u2f_data' =>
'{"keyHandle":"4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s4","clientData":"eyJjaGFsbGVuZ2UiOiJZejNVWVFmcW1hRWljenhxa1lYOGdpMzFuOTktYnFRWl9uUkxMd3NMOUdNIiwibmV3X2tleXNfbWF5X2JlX2FkZGVkX2hlcmUiOiJkbyBub3QgY29tcGFyZSBjbGllbnREYXRhSlNPTiBhZ2FpbnN0IGEgdGVtcGxhdGUuIFNlZSBodHRwczovL2dvby5nbC95YWJQZXgiLCJvcmlnaW4iOiJodHRwczovL2luc2VjdXJlLmRlbW8iLCJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIn0","signatureData":"AQAAAAIwRQIgRwQ2BELLkX9MFJtcAKlIFcZ2paFipj97DUCeVefACPgCIQDtZFMfNUMXokEMDozM2Kls3o3OhTP9J1h67iR5-2nYPw"}',
            ]
        );
    }, [ match('Crypto error') ];

    like $response->content, qr'problem authenticating';
    isnt $response->header('location'), 'http://localhost/admin';
    ok !grep { /user=/ } $response->headers->header('set-cookie'),
      'user cookie should be set';
};

subtest 'Valid challenge for same key, but different site' => sub {

    # replay a valid u2f key exchange from evil.fake
    # essentially trying to check we validate that the challenge
    # really came from us.
    # since we can't strictly speaking trust the challange since
    # it too is coming back from the user.
    my $mock = setup_mock(
        keys => [
            {
                key_handle => $evilsite_handle,
                user_key   => $evilsite_user_key,
            },
        ]
    );

    my $response;
    is warnings {
        $response = $test->request(
            POST '/u2f',
            Cookie  => 'userid=1; login=foo',
            Content => [
                challenge => 'pvvC30ftRUYX8U-X5rN9rERMr_3qyndTdSFQi455xtc',
                'u2f_data' =>
'{"keyHandle":"hUYC_FIPUydNLLUGc-wT8KZhXhvoGPtWMXcqS8i5ND5v8pnlkp0uWrHbzX9TqlYhMhm-KYXzSkHcazOOvxGmb-MK6-zwwb4tfgycfVvc8i9FlR2taydeFPlwJ_vkZgbj","clientData":"eyJjaGFsbGVuZ2UiOiJwdnZDMzBmdFJVWVg4VS1YNXJOOXJFUk1yXzNxeW5kVGRTRlFpNDU1eHRjIiwib3JpZ2luIjoiaHR0cHM6Ly9ldmlsLmZha2UiLCJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIn0","signatureData":"AQAAAAkwRQIgELxIqvTlgj0mMsm7aJEepxKZ6wqzNCRECjcqp-9-gPUCIQCZhijeMLhLnnythCC61OxczL4OX_SdjgsfNTLDWVNjVQ"}',
            ]
        );
    }, [ match('Crypto error') ];

    like $response->content, qr'problem authenticating';
    isnt $response->header('location'), 'http://localhost/admin';
    ok !grep { /user=/ } $response->headers->header('set-cookie'),
      'user cookie should be set';
};

subtest 'Bad key data' => sub {
    my $mock = setup_mock(
        keys => [
            {
                key_handle => $fake_but_plausible_key_handle,
                user_key   => $fake_but_plausible_user_key,
            },
        ]
    );

    my $response;
    is warnings {
        $response = $test->request(
            POST '/u2f',
            Cookie  => 'userid=1; login=foo',
            Content => [
                challenge => 'Yz3UYQfqmaEiczxqkYX8gi31n99-bqQZ_nRLLwsL9GM',
                'u2f_data' =>
'{"keyHandle":"4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s3","clientData":"eyJjaGFsbGVuZ2UiOiJZejNVWVFmcW1hRWljenhxa1lYOGdpMzFuOTktYnFRWl9uUkxMd3NMOUdNIiwibmV3X2tleXNfbWF5X2JlX2FkZGVkX2hlcmUiOiJkbyBub3QgY29tcGFyZSBjbGllbnREYXRhSlNPTiBhZ2FpbnN0IGEgdGVtcGxhdGUuIFNlZSBodHRwczovL2dvby5nbC95YWJQZXgiLCJvcmlnaW4iOiJodHRwczovL2luc2VjdXJlLmRlbW8iLCJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIn0","signatureData":"AQAAAAIwRQIgRwQ2BELLkX9MFJtcAKlIFcZ2paFipj97DUCeVefACPgCIQDtZFMfNUMXokEMDozM2Kls3o3OhTP9J1h67iR5-2nYPw"}',
            ]
        );
    }, [ match('Crypto error') ];

    like $response->content, qr'problem authenticating';
    isnt $response->header('location'), 'http://localhost/admin';
    ok !grep { /user=/ } $response->headers->header('set-cookie'),
      'user cookie should be set';
};

done_testing;

sub setup_mock {
    my %args = @_;

    return mock 'Insecure::Demo::Service::Users' => override => [
        get_user_id   => sub { 1 },
        get_user      => sub { ( undef, '/admin' ) },
        load_u2f_keys => sub { return $args{keys}; },
    ];
}
