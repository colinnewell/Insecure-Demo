package Insecure::Demo::Admin;

use Dancer2 appname => 'admin';
use Insecure::Demo::Container 'service';
use Insecure::Demo::Form::User;
use Insecure::Demo::Form::Password;

prefix '/login' => sub {
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
        my $ret      = service('Users')->user_step($username);
        cookie 'login' => $ret->{auth_cookie}, expires => "2 hours";
        redirect '/login/pwd';
    };

    any '/pwd' => sub {
        my $logins_cookie = cookies->{login};
        redirect '/login/' unless $logins_cookie;
        my $user = service('Users')->get_user( $logins_cookie->value );
        redirect '/login/' unless $user;
        my $form = Insecure::Demo::Form::Password->new;
        $form->process( defaults => { username => $user } );
        var form => $form;
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
          expiry_time               => $retval->{expiry};
        if ( $retval->{next} eq 'done' ) {
            redirect '/admin';
        }
        else {
            redirect '/login/' . $retval->{next};
        }
    };

    get '/u2f' => sub {
    };

    post '/u2f' => sub {
    };
};

1;
