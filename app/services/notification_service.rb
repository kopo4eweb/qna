# frozen_string_literal: true

class NotificationService
  def send_notifications(answer)
    subscriptions = Subscription.where(question: answer.question.id)
    subscriptions.find_each(batch_size: 500) do |subscription|
      NotificationMailer.question_notification(subscription.user, answer).deliver_later
    end
  end
end
