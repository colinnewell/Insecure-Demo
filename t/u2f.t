use Test2::V0;

use HTTP::Request::Common;
use Insecure::Demo::Admin::Login;
use Insecure::Demo::Service::Users;
use Plack::Test;

my $mock = mock 'Insecure::Demo::Service::Users' => override => [
    get_user_id => sub { 1 },
    get_user    => sub { ( undef, '/admin' ) },
    load_u2f_keys => sub {
        [
            {
                key_handle =>
'4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s4',
                user_key => pack 'H*',
'045855059149d36a6e8161fe7f2d49fe19168b598889dc076a80892aa4fafa86e9830e3844a0428d5e257ce53594c6226dc10f44d25427fd99db547664564ee961',
            },
            {
                key_handle =>
'4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s3',
                user_key => pack 'H*',
'045855059149d36a6e8161fe7f2d49fe19168b598889dc076a80892aa4fafa86e9830e3844a0428d5e257ce53594c6226dc10f44d25427fd99db547664564ee962',
            },
        ]
    }
];

my $test = Plack::Test->create( Insecure::Demo::Admin::Login->to_app );

my $response = $test->request( GET '/u2f', Cookie => 'userid=1; login=foo', );
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

done_testing;
