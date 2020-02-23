$(function() {
    var dialog = $('div.dialog.entry').dialog({
        autoOpen: false,
        height: 400,
        width: 350,
        modal: true,
        buttons: {
            'Save': function() {
                // grab the info
                $.post('/admin/time-logger/entry', $('.dialog.entry form').serializeArray(), function(data) {
                    if(data.success) {
                        // update the table with the entry.
                        var $row = $('<tr>');
                        var fields = ['code', 'title', 'seconds'];
                        fields.forEach(x =>
                            $row.append($('<td>' + $('#' + x).val() + '</td>')));
                        $row.append($('<td>' + users_name + '</td>'));

                        $('table.times tr:last').after($row);
                        // clear the form
                        $('.dialog.entry input').val('');
                        // should get the ticket title back
                    }
                    // FIXME: do something on error
                });
                dialog.dialog('close');
            },
            'Cancel': function() {
                dialog.dialog('close');
            },
        }
    });
    var add_link = $('<a>', { href: '#' }).text('Log Entry').click(function() {
        dialog.dialog('open');
        $('input#code').focus();
    });
    $('table').after(add_link);

    var new_ticket_dialog = $('div.dialog.ticket').dialog({
        autoOpen: false,
        height: 400,
        width: 350,
        modal: true,
        buttons: {
            'Save': function() {
                // grab the info
                $.post('/admin/time-logger/ticket', $('.dialog.ticket form').serializeArray(), function(data) {
                    if(data.success) {
                        $('#code').val($('#new_code').val() +
                            ' ' + $('#title').val());
                        $('#ticket_id').val(data.ticket_id);
                        // clear the form
                        $('.dialog.ticket input').val('');
                    } else {
                        // re-open the dialog so they
                        // can do someting
                        new_ticket_dialog.dialog('open');
                        alert(data.error);
                    }
                });
                new_ticket_dialog.dialog('close');
            },
            'Cancel': function() {
                new_ticket_dialog.dialog('close');
            },
        }
    });
    var new_ticket = $('<a>', { href: '#' }).text('New Ticket').click(function() {
        new_ticket_dialog.dialog('open');
    });
    $('#code').after(new_ticket);
    $('#code').autocomplete({
        source: "/admin/time-logger/tickets",
        minLength: 3,
        select: function( event, ui ) {
            $('#ticket_id').val(ui.item.id);
        }
    });

    // add autocomplete and new ticket link to dialog.
});

