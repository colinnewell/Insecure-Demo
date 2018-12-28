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

1;
