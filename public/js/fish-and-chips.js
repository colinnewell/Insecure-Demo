$(function() {
    var $elem = $('<td>').append($('<a class="edit" href="#">').text('Edit'));
    $elem.appendTo('.orders tr.line');
    var dialog = $('div.dialog').dialog({
        autoOpen: false,
        height: 400,
        width: 350,
        modal: true,
        buttons: {
            'Save': function() {
                dialog.dialog('close');
            },
            'Cancel': function() {
                dialog.dialog('close');
            },
        }
    });
    $('.orders').on('click', 'a.edit', function() {
        var $row = $(this).closest('tr');
        var id = $row[0].dataset.id;
        $('#food').val($row.find('.food').text());
        var name = $row.find('.name').text();
        $('#user_id option').filter( function() {
            return $(this).text() === name
        } ).prop('selected', true);;
        dialog.dialog('open');
        return false;
    });
});
