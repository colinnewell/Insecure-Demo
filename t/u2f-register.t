use Test2::V0;

use HTTP::Request::Common;
use Insecure::Demo::Admin::Config;
use Insecure::Demo::Service::Users;
use Plack::Test;

my $mock = mock 'Insecure::Demo::Service::Users' => override =>
  [ 'store_u2f_key' => sub { }, ];

my $test = Plack::Test->create( Insecure::Demo::Admin::Config->to_app );

my $response = $test->request(
    POST '/u2f-register',
    Content => [
        'u2f_data' =>
'{"registrationData":"BQRYVQWRSdNqboFh_n8tSf4ZFotZiIncB2qAiSqk-vqG6YMOOESgQo1eJXzlNZTGIm3BD0TSVCf9mdtUdmRWTulhYOMQqSc3m1GHP6--BcDZpy92BImdKgHBTv8pMEjGlw8eEbCMiftP21aAOg5ai3LqUdTZUlIZaWkhZEl7xFYe_FiTaTQ7dYsgQgvH9FEqCQ4ivAytHOh7f0zgR3DO8KOLODCCATUwgdygAwIBAgILANz21mbrnBZqfncwCgYIKoZIzj0EAwIwFTETMBEGA1UEAxMKVTJGIElzc3VlcjAaFwswMDAxMDEwMDAwWhcLMDAwMTAxMDAwMFowFTETMBEGA1UEAxMKVTJGIERldmljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABKcuf41J4SBNJITauzhKcLIOF1Cf1fieQHAiQwQw-uNomxcNzKlDb2yxv4PZsLwoq-5VpCbDIQt7qkM38OKNr12jFzAVMBMGCysGAQQBguUcAgEBBAQDAgUgMAoGCCqGSM49BAMCA0gAMEUCIQDBo6aOLxanIUYnBX9iu3KMngPnobpi0EZSTkVtLC8_cwIgC1945RGqGBKfbyNtkhMifZK05n7fU-gW37Bdnci5D94wRgIhAKjy6szqXisi5Pn-UMQsIkLV_c8LBXbtHANj_8MgABf1AiEAw-FBqtLPrlcizuotVz6yFRQubwvHpjZdvSEfwwFayS0","challenge":"qRmL6wnpz9EkeoUuTGQdlo2_0rQPRHu19ti0E4_zgKY","version":"U2F_V2","clientData":"eyJjaGFsbGVuZ2UiOiJxUm1MNnducHo5RWtlb1V1VEdRZGxvMl8wclFQUkh1MTl0aTBFNF96Z0tZIiwib3JpZ2luIjoiaHR0cHM6Ly9pbnNlY3VyZS5kZW1vIiwidHlwIjoibmF2aWdhdG9yLmlkLmZpbmlzaEVucm9sbG1lbnQifQ"}'
    ]
);
is $response->header('location'), 'http://localhost/u2f-registered';

done_testing;
