package Insecure::Demo::Admin::Login;

use Dancer2 appname => 'login';
use Insecure::Demo::Container 'service';
use Insecure::Demo::Form::User;
use Insecure::Demo::Form::Password;

any '/' => sub {
    var form => Insecure::Demo::Form::User->new;
    pass;
};

get '/' => sub {
    template 'login';
};

post '/' => sub {
    my $form = vars->{form};
    unless ( $form->process( params => body_parameters->as_hashref ) ) {
        template 'login';
    }
    my $username = $form->field('username')->value;
    my $ret      = service('Users')
      ->user_step( $username, return_url => query_parameters->get('return') );
    cookie
      'login'   => $ret->{auth_cookie},
      expires   => "+2h",
      secure    => 1,
      http_only => 1;
    redirect '/pwd';
};

any '/pwd' => sub {
    my $logins_cookie = cookies->{login};
    redirect '/' unless $logins_cookie;
    my ( $user, $return_url ) =
      service('Users')->get_user( $logins_cookie->value );
    redirect '/' unless $user;
    my $form = Insecure::Demo::Form::Password->new;
    $form->process( defaults => { username => $user } );
    var form       => $form;
    var return_url => $return_url;
    pass;
};

get '/pwd' => sub {
    template 'login';
};

post '/pwd' => sub {
    my $form = vars->{form};
    unless ( $form->process( params => body_parameters->as_hashref ) ) {
        template 'login';
    }
    my $username = $form->field('username')->value;
    my $password = $form->field('password')->value;
    my $retval   = service('Users')->user_valid( $username, $password );
    if ( $retval->{fail} ) {
        $form->field('password')->add_error('Invalid username or password');
        return template 'login';
    }
    cookie $retval->{token_key} => $retval->{token},
      expires                   => $retval->{expiry},
      secure                    => 1,
      http_only                 => 1;
    if ( $retval->{next} eq 'done' ) {

        _delete_cookies('login');

        if ( vars->{return_url} =~ m|^/| ) {
            redirect 'http://' . request->host . vars->{return_url};
        }

        redirect 'http://' . request->host . '/admin';
    }
    else {
        redirect '/' . $retval->{next};
    }
};

any '/u2f' => sub {
    my $user_id;
    my $token = cookies->{userid};
    my $srv   = service('Users');
    $user_id = $srv->get_user_id($token) if $token;
    redirect '/' unless $user_id;
    my $logins_cookie = cookies->{login};
    redirect '/' unless $logins_cookie;
    my ( undef, $return_url ) =
      service('Users')->get_user( $logins_cookie->value );
    var return_url => $return_url;
    var srv        => $srv;
    var user_id    => $user_id;
    pass;
};

get '/u2f' => sub {
    my $user_id = vars->{user_id};

    my $auth = service('U2F')->get_u2f_auth_challenge( user_id => $user_id, );
    template 'u2f-auth',
      {
        app_id    => $auth->{appId},
        challenge => $auth->{challenge},
        keys      => [
            {
                keyHandle => $auth->{keyHandle},
                version   => $auth->{version}
            }
        ],
      };
};

post '/u2f' => sub {
    my $user_id = vars->{user_id};

    my $data = eval { decode_json body_parameters->get('u2f_data') };
    warn $@ if $@;
    status 400 unless $data;

    # FIXME: do I need to authenticate that the challenge came from us?
    if (
        service('U2F')->u2f_valid(
            auth_response => $data,
            user_id       => $user_id,
            challenge     => body_parameters->get('challenge')
        )
      )
    {
        # set login cookie
        cookie
          'user' =>
          vars->{srv}->_login_token( $user_id, expiry_time => 8 * 60 * 60 ),
          expires   => '+8h',
          secure    => 1,
          http_only => 1;

        _delete_cookies( 'login', 'userid' );

        if ( vars->{return_url} =~ m|^/| ) {
            redirect 'http://' . request->host . vars->{return_url};
        }

        redirect 'http://' . request->host . '/admin';
    }

    # FIXME: figure out a proper failure thing
    redirect '/';
};

sub _delete_cookies {
    my @cookies = @_;

    cookie $_ => '', expires => '-1d' for @cookies;
}
1;
