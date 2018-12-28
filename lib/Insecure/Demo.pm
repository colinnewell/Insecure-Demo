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

true;
