$(function() {
    var $elem = $('<td>').append($('<a class="edit" href="#">').text('Edit'));
    $elem.appendTo('.orders tr.line');
    var id;
    var $row;
    var dialog = $('div.dialog').dialog({
        autoOpen: false,
        height: 400,
        width: 350,
        modal: true,
        buttons: {
            'Save': function() {
                // grab the info
                $.post('/admin/fish-and-chips/edit/' + id, $('.dialog form').serializeArray(), function(data) {
                    if(data.success) {
                        // update the ui
                        $row.find('.food').text(data.food);
                        $row.find('.name').text(data.name);
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
    $('.orders').on('click', 'a.edit', function() {
        $row = $(this).closest('tr');
        id = $row[0].dataset.id;
        $('#food').val($row.find('.food').text());
        var name = $row.find('.name').text();
        $('#user_id option').filter( function() {
            return $(this).text() === name
        } ).prop('selected', true);;
        dialog.dialog('open');
        return false;
    });
});
