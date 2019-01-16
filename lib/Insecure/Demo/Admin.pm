package Insecure::Demo::Admin;

use Dancer2 appname => 'admin';
use Insecure::Demo::Container 'service';

use DateTime;

get '/' => sub {
    template 'admin';
};

get '/fish-and-chips' => sub {
    my $date = query_parameters->get('date') || DateTime->today->ymd;
    my $order_data = service('FishAndChips')->orders(
        date     => $date,
        limit    => query_parameters->get('limit'),
        offset   => query_parameters->get('offset'),
        order_by => query_parameters->get('order_by'),
    );
    my $users = service('Users')->user_list;
    template 'fish-and-chips',
      { title => 'Fish and Chips', orders => $order_data, users => $users };
};

post '/fish-and-chips' => sub {
    eval {
        service('FishAndChips')->add_order(
            name => request->env->{ID_NAME},
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
    eval {
        my $user_id = body_parameters->get('user_id');

        my $user_details = service('Users')->user_details($user_id);
        die 'Unable to find user ' . $user_id unless $user_details;

        my %data = (
            id   => route_parameters->get('id'),
            name => $user_details->{ID_NAME},
            food => body_parameters->get('food'),
        );
        service('FishAndChips')->edit_order(%data);
        $message = { success => 1, %data };
    };
    if ($@) {
        warn $@;
        $message = { fail => 1 };
    }
    send_as JSON => $message;
};

get '/number-check' => sub {
    template 'number-check';
};

post '/number-check' => sub {
    my $number = body_parameters->get('number');
    my $office =
      service('DBIC')->resultset('OfficeNumbers')->office_lookup($number);
    template 'number-check' => { number => $number, office => $office->first };
};

get '/users' => sub {
    return status 403 unless request->env->{ID_ADMIN};
    template 'users' => { users => service('Users')->user_list };
};

1;
