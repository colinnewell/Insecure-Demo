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
    cookie 'login' => $ret->{auth_cookie}, expires => "+2h";
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
      expires                   => $retval->{expiry};
    if ( $retval->{next} eq 'done' ) {

        _delete_cookies('login');

        if ( vars->{return_url} =~ m|^/| ) {
            redirect 'http://' . request->host . vars->{return_url};
        }

        # FIXME: this is a bit brittle using the http
        redirect 'http://' . request->host . '/admin';
    }
    else {
        redirect '/' . $retval->{next};
    }
};

get '/u2f' => sub {
};

post '/u2f' => sub {
};

sub _delete_cookies {
    my @cookies = @_;

    cookie $_ => '', expires => '-1d' for @cookies;
}
1;
