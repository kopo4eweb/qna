# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def question_notification(user, answer)
    @question = answer.question
    @answer = answer

    mail to: user.email, subject: "Updating question: #{@question.title}"
  end
end
