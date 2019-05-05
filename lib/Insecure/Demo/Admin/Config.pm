package Insecure::Demo::Admin::Config;

use Cpanel::JSON::XS 'decode_json';
use Dancer2 appname => 'config';
use Insecure::Demo::Container 'service';

get 'u2f-register' => sub {
    my $challenge =
      decode_json( service('U2F')->get_u2f_registration_challenge );
    delete $challenge->{appId};
    my $keys =
      service('Users')->load_u2f_keys( user_id => request->env->{ID_ID}, );

    template 'u2f-register' => {
        app_id => service('U2F')->origin,
        keys   => [
            map {
                {
                    keyHandle => $_->{key_handle},
                    version   => $challenge->{version},
                }
            } @{$keys}
        ],
        u2f_challenge => $challenge,
    };
};

post 'u2f-register' => sub {
    my $data = eval { decode_json body_parameters->get('u2f_data') };
    warn $@ if $@;
    status 400 unless $data;

    eval {
        service('U2F')->set_u2f_registration_challenge(
            response => $data,
            user_id  => request->env->{ID_ID},
        );
    };
    if ($@) {
        warn $@;
        return template 'u2f-register', { problem => 1 };
    }

    redirect '/u2f-registered';
};

get 'u2f-registered' => sub {
    template 'u2f-registered';
};

1;
