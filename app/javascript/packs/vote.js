$(document).on('turbolinks:load', function() {
  $('.vote-up, .vote-down, .cancel-vote')
    .on('ajax:success', function(data) {
      const vote = data.detail[0];
      const parent = $(this).closest('.vote');

      parent.find('.vote-errors').hide();
      parent.find('.vote-result').html(vote.total_votes);

      parent.find('.vote-up, .vote-down').toggle();
      parent.find('.cancel-vote').toggle();
    })
    .on('ajax:error', function(data) {
      const parent = $(this).closest('.vote');
      const error = data.detail[0];

      parent.find('.vote-errors').html(error).show();
    });
});