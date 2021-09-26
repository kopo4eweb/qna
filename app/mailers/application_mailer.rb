# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'send@kopo4e.ru'
  layout 'mailer'
end
