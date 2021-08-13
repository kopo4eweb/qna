$(document).on('turbolinks:load', function() {
  $('.question-detail, .answers').on('click', '.btn-add-comment', function (e) {
    e.preventDefault();

    var link = $(this),
        form_selector = link.data('form');

    $(form_selector).toggle();
  });
});
