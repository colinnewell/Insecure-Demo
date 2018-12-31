$(function() {
    var $elem = $('<td>').append($('<a class="edit" href="#">').text('Edit'));
    $elem.appendTo('.orders tr.line');
    $('.orders').on('click', 'a.edit', function() {
        var row = $(this).closest('tr')[0];
        var id = row.dataset.id;
        // FIXME: populate the dialog
        // display it.
        return false;
    });
});
