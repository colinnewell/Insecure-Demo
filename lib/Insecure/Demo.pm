package Insecure::Demo;

use Dancer2;
use Insecure::Demo::Container 'service';

# ABSTRACT: demonstration application with security issues

our $VERSION = '0.001';

any '/' => sub {

    # prevent naughty people from doing naughty things.
    if (
        service('BannedUsers')->is_client_banned(
            client         => request->user_agent     || '',
            referer        => request->referer        || '',
            remote_address => request->remote_address || '',
        )
      )
    {
        # is this the best way to bounce them?
        status 400;
    }
    pass;
};

get '/' => sub {
    template 'index' => { 'title' => 'Insecure::Demo' };
};

get '/feedback' => sub {
    template 'feedback';
};

post '/feedback' => sub {
    my $name     = body_parameters->get('name');
    my $comments = body_parameters->get('comments');

    my %required = ( ( comments => 1 ) x !$comments, ( name => 1 ) x !$name, );

    if (%required) {
        return template 'feedback' => {
            comments => $comments,
            name     => $name,
            required => \%required,
        };
    }

    # FIXME: pack the ip address to an integer
    my $ip = 0;    #request->env->{''};
    service('Feedback')
      ->store_feedback( ip => $ip, name => $name, comments => $comments );

    redirect '/';
};

true;
