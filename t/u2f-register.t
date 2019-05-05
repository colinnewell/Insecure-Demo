use Test2::V0;
use Test2::Plugin::NoWarnings;

use HTTP::Request::Common;
use Insecure::Demo::Admin::Config;
use Insecure::Demo::Service::Users;
use Plack::Test;

# FIXME: should I be storing version alongside key?
my $valid_key_handle =
'4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s4';
my $valid_user_key = pack 'H*',
'045855059149d36a6e8161fe7f2d49fe19168b598889dc076a80892aa4fafa86e9830e3844a0428d5e257ce53594c6226dc10f44d25427fd99db547664564ee961';
my $fake_but_plausible_key_handle =
'4xCpJzebUYc_r74FwNmnL3YEiZ0qAcFO_ykwSMaXDx4RsIyJ-0_bVoA6DlqLcupR1NlSUhlpaSFkSXvEVh78WJNpNDt1iyBCC8f0USoJDiK8DK0c6Ht_TOBHcM7wo4s3';
my $fake_but_plausible_user_key = pack 'H*',
'045855059149d36a6e8161fe7f2d49fe19168b598889dc076a80892aa4fafa86e9830e3844a0428d5e257ce53594c6226dc10f44d25427fd99db547664564ee962';

my $test = Plack::Test->create( Insecure::Demo::Admin::Config->to_app );

subtest 'Simple register' => sub {
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

    my $response = $test->request( GET '/u2f-register' );
    like $response->content, qr'keyHandle.*keyHandle';

    $response = $test->request(
        POST '/u2f-register',
        Content => [
            'u2f_data' =>
'{"registrationData":"BQRYVQWRSdNqboFh_n8tSf4ZFotZiIncB2qAiSqk-vqG6YMOOESgQo1eJXzlNZTGIm3BD0TSVCf9mdtUdmRWTulhYOMQqSc3m1GHP6--BcDZpy92BImdKgHBTv8pMEjGlw8eEbCMiftP21aAOg5ai3LqUdTZUlIZaWkhZEl7xFYe_FiTaTQ7dYsgQgvH9FEqCQ4ivAytHOh7f0zgR3DO8KOLODCCATUwgdygAwIBAgILANz21mbrnBZqfncwCgYIKoZIzj0EAwIwFTETMBEGA1UEAxMKVTJGIElzc3VlcjAaFwswMDAxMDEwMDAwWhcLMDAwMTAxMDAwMFowFTETMBEGA1UEAxMKVTJGIERldmljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABKcuf41J4SBNJITauzhKcLIOF1Cf1fieQHAiQwQw-uNomxcNzKlDb2yxv4PZsLwoq-5VpCbDIQt7qkM38OKNr12jFzAVMBMGCysGAQQBguUcAgEBBAQDAgUgMAoGCCqGSM49BAMCA0gAMEUCIQDBo6aOLxanIUYnBX9iu3KMngPnobpi0EZSTkVtLC8_cwIgC1945RGqGBKfbyNtkhMifZK05n7fU-gW37Bdnci5D94wRgIhAKjy6szqXisi5Pn-UMQsIkLV_c8LBXbtHANj_8MgABf1AiEAw-FBqtLPrlcizuotVz6yFRQubwvHpjZdvSEfwwFayS0","challenge":"qRmL6wnpz9EkeoUuTGQdlo2_0rQPRHu19ti0E4_zgKY","version":"U2F_V2","clientData":"eyJjaGFsbGVuZ2UiOiJxUm1MNnducHo5RWtlb1V1VEdRZGxvMl8wclFQUkh1MTl0aTBFNF96Z0tZIiwib3JpZ2luIjoiaHR0cHM6Ly9pbnNlY3VyZS5kZW1vIiwidHlwIjoibmF2aWdhdG9yLmlkLmZpbmlzaEVucm9sbG1lbnQifQ"}'
        ]
    );
    is $response->header('location'), 'http://localhost/u2f-registered';
};

subtest 'Register with messed up registration data' => sub {
    my $mock = setup_mock();

    my $response;
    is warnings {
        $response = $test->request(
            POST '/u2f-register',
            Content => [
                'u2f_data' =>
'{"registrationData":"BQaYVQWRSdNqboFh_n8tSf4ZFotZiIncB2qAiSqk-vqG6YMOOESgQo1eJXzlNZTGIm3BD0TSVCf9mdtUdmRWTulhYOMQqSc3m1GHP6--BcDZpy92BImdKgHBTv8pMEjGlw8eEbCMiftP21aAOg5ai3LqUdTZUlIZaWkhZEl7xFYe_FiTaTQ7dYsgQgvH9FEqCQ4ivAytHOh7f0zgR3DO8KOLODCCATUwgdygAwIBAgILANz21mbrnBZqfncwCgYIKoZIzj0EAwIwFTETMBEGA1UEAxMKVTJGIElzc3VlcjAaFwswMDAxMDEwMDAwWhcLMDAwMTAxMDAwMFowFTETMBEGA1UEAxMKVTJGIERldmljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABKcuf41J4SBNJITauzhKcLIOF1Cf1fieQHAiQwQw-uNomxcNzKlDb2yxv4PZsLwoq-5VpCbDIQt7qkM38OKNr12jFzAVMBMGCysGAQQBguUcAgEBBAQDAgUgMAoGCCqGSM49BAMCA0gAMEUCIQDBo6aOLxanIUYnBX9iu3KMngPnobpi0EZSTkVtLC8_cwIgC1945RGqGBKfbyNtkhMifZK05n7fU-gW37Bdnci5D94wRgIhAKjy6szqXisi5Pn-UMQsIkLV_c8LBXbtHANj_8MgABf1AiEAw-FBqtLPrlcizuotVz6yFRQubwvHpjZdvSEfwwFayS0","challenge":"qRmL6wnpz9EkeoUuTGQdlo2_0rQPRHu19ti0E4_zgKY","version":"U2F_V2","clientData":"eyJjaGFsbGVuZ2UiOiJxUm1MNnducHo5RWtlb1V1VEdRZGxvMl8wclFQUkh1MTl0aTBFNF96Z0tZIiwib3JpZ2luIjoiaHR0cHM6Ly9pbnNlY3VyZS5kZW1vIiwidHlwIjoibmF2aWdhdG9yLmlkLmZpbmlzaEVucm9sbG1lbnQifQ"}'
            ]
          )
    }, [ match('Unable to verify signature') ];

    like $response->content, qr'Failed to register key';
    isnt $response->header('location'), 'http://localhost/u2f-registered';
};

done_testing;

sub setup_mock {
    my %args = @_;

    return mock 'Insecure::Demo::Service::Users' => override => [
        load_u2f_keys => sub {
            return $args{keys};
        },
        store_u2f_key => sub { },
    ];
}
