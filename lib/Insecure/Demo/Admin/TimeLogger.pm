package Insecure::Demo::Admin::TimeLogger;

use Dancer2 appname => 'timelogger';
use Insecure::Demo::Container 'service';
use Try::Tiny;

get '/' => sub {
    my $entries = service('TimeLogging')->entries( request->env->{ID_ID} );
    template 'time-logger', { entries => $entries };
};

get '/all-entries' => sub {
    return status 403 unless request->env->{ID_ADMIN};

    my $entries = service('TimeLogging')->entries(undef);
    template 'time-logger', { entries => $entries };
};

post 'entry' => sub {
    service('TimeLogging')->create(
        seconds   => body_parameters->get('seconds'),
        ticket_id => body_parameters->get('ticket_id'),
        user_id   => request->env->{ID_ID},
    );
    send_as JSON => { success => 1 };
};

post 'ticket' => sub {
    my $id = try {
        service('TimeLogging')->create_ticket(
            code  => body_parameters->get('new_code'),
            title => body_parameters->get('title')
        );
    } catch {
        my $error = 'unknown';
        if(/duplicate/i) {
            $error = 'duplicate';
        } else {
            warn $_;
        }
        send_as JSON => { error => $error };
    };
    send_as JSON => { success => 1, ticket_id => $id };
};

get '/tickets' => sub {
    my $tickets = service('TimeLogging')
      ->search_tickets( term => query_parameters->get('term') );
    send_as JSON => $tickets;
};

1;
