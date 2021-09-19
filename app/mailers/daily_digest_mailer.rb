# frozen_string_literal: true

class DailyDigestMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.daily_digest_mailer.digest.subject
  #
  def digest(user)
    @questions = Question.created_in_a_day
    @user = user

    mail to: user.email, subject: 'Daily Digest from Qna' if @questions.present?
  end
end
