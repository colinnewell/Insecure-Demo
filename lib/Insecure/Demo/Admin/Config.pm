package Insecure::Demo::Admin::Config;

use Cpanel::JSON::XS 'decode_json';
use Dancer2 appname => 'config';
use Insecure::Demo::Container 'service';

get 'u2f-register' => sub {
    my $challenge =
      decode_json( service('Users')->get_u2f_registration_challenge );
    delete $challenge->{appId};
    template 'u2f-register' => {
        app_id        => service('Users')->u2f->{origin},
        u2f_challenge => $challenge
    };
};

post 'u2f-register' => sub {
    my $data = eval { decode_json body_parameters->get('u2f_data') };
    warn $@ if $@;
    status 400 unless $data;

    service('Users')->set_u2f_registration_challenge(
        response => $data,
        user_id  => request->env->{ID_ID},
    );

    redirect '/u2f-registered';
};

get 'u2f-registered' => sub {
    template 'u2f-registered';
};

1;
