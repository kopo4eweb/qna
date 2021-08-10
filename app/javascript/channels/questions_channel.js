import consumer from "./consumer"

consumer.subscriptions.create("QuestionsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (data.event === 'add') {
      $('.questions').append(data.body)
    }
    if (data.event === 'update') {
      $('.question-' + data.id).replaceWith(data.body)
    }
    if (data.event === 'destroy') {
      $('.question-' + data.id).remove()
    }
  }
});