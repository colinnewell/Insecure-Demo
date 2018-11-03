package Insecure::Demo;

use Dancer2;
use File::ShareDir 'module_dir';
use Insecure::Demo::Container 'service';
use Path::Tiny;

# ABSTRACT: demonstration application with security issues

set appname => 'Insecure::Demo';
set charset => 'UTF-8';
set engines => { template => { AUTO_FILTER => 'html' } };
set layout  => 'main';
set public_dir =>
  path( module_dir('Insecure::Demo') )->child('public')->stringify;
set template => 'alloy';
set views    => path( module_dir('Insecure::Demo') )->child('views')->stringify;

our $VERSION = '0.001';

any '/' => sub {

    # prevent naughty people from doing naughty things.
    if (
        service('BannedUsers')->is_client_banned(
            client         => request->user_agent     || '',
            referer        => request->referer        || '',
            remote_address => request->remote_address || '',
            email          => $email,
        )
      )
    {
        # is this the best way to bounce them?
        status 400;
    }
};

get '/' => sub {
    template 'index' => { 'title' => 'Insecure::Demo' };
};

true;
