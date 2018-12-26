package Insecure::Demo;

use Dancer2;
use DateTime;
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

get '/fish-and-chips' => sub {
    my $date = query_parameters->get('date') || DateTime->today->ymd;
    my $order_data = service('FishAndChips')->orders(
        date     => $date,
        limit    => query_parameters->get('limit'),
        offset   => query_parameters->get('offset'),
        order_by => query_parameters->get('order_by'),
    );
    template 'fish-and-chips',
      { title => 'Fish and Chips', orders => $order_data };
};

post '/fish-and-chips' => sub {
    eval {
        my $order = service('FishAndChips')->add_order(
            name => body_parameters->get('name'),
            food => body_parameters->get('food'),
        );
    };
    if ($@) {

        # FIXME: do something about this.
        warn $@;
    }
    redirect request->uri;
};

get '/paste-bin' => sub {
};

post '/paste-bin' => sub {
    my $data = request->upload('file');
};


true;
