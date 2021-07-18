$(document).on('turbolinks:load', function() {
  $('.answers').on('click', '.edit-answer-link', function(e) {
    e.preventDefault();

    var link = $(this),
        answerId = link.data('answerId');

    link.hide();
    $('.edit-answer-' + answerId).show();
  });

  $('.answers').on('click', '.cancel-answer-link', function(e) {
    e.preventDefault();

    var link = $(this),
      answerId = link.data('answerId'),
      answerBlock = $('.answer-' + answerId);

    answerBlock.find('.edit-answer-link').show();
    answerBlock.find('.edit-answer-' + answerId).hide();
  });
});
