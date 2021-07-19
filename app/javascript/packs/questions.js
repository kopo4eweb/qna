$(document).on('turbolinks:load', function() {
  $('.questions').on('click', '.edit-question-link', function(e) {
    e.preventDefault();

    var link = $(this),
        questionId = link.data('questionId');

    link.hide();
    $('.edit-question-' + questionId).show();
  });

  $('.questions').on('click', '.cancel-question-link', function(e) {
    e.preventDefault();

    var link = $(this),
      questionId = link.data('questionId'),
      questionBlock = $('.question-' + questionId);

    questionBlock.find('.edit-question-link').show();
    questionBlock.find('.edit-question-' + questionId).hide();
  });
});
