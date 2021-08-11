import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AnswersChannel", question_id: gon.question_id }, {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (data.author_id !== gon.current_user_id) {
      if (data.event === 'add') {
        $('.question-' + data.question_id + '-answers').append(data.body)
      }
      if (data.event === 'update') {
        $('.answer-' + data.id).replaceWith(data.body)
      }
      if (data.event === 'destroy') {
        $('.answer-' + data.id).remove()
      }
    }
  }
});