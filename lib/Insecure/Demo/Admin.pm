package Insecure::Demo::Admin;

use Dancer2 appname => 'admin';
use Insecure::Demo::Container 'service';

use DateTime;

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
            name => request->env->{APP_NAME},
            food => body_parameters->get('food'),
        );
    };
    if ($@) {

        # FIXME: do something about this.
        warn $@;
    }
    redirect 'fish-and-chips';
};

post '/fish-and-chips/edit/:id' => sub {
    my $message = {};
    my $srv     = service('FishAndChips');
    eval {
        my $user_id = body_parameters->get('user_id');

        my $user_details = $srv->user_details($user_id);
        die 'Unable to find user ' . $user_id unless $user_details;

        my $order =->edit_order(
            id   => body_parameters->get('id'),
            name => $user_details->{username},
            food => body_parameters->get('food'),
        );
        $message = { success => 1 };
    };
    if ($@) {
        warn $@;
        $message = { fail => 1 };
    }
    send_as JSON => $message;
};

1;
