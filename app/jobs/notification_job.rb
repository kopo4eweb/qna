# frozen_string_literal: true

class NotificationJob < ApplicationJob
  queue_as :default

  def perform(answer)
    NotificationService.new.send_notifications(answer)
  end
end
