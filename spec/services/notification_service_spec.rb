# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/NamedSubject
RSpec.describe NotificationService do
  let!(:user) { create(:user) }
  let!(:question) { create(:question) }
  let!(:answer) { create(:answer, question: question) }

  it 'sends information users about update question' do
    create(:subscription, question: question, user: user)

    # rubocop:disable RSpec/MessageSpies
    question.subscriptions.each do |subscription|
      expect(NotificationMailer).to receive(:question_notification).with(subscription.user, answer).and_call_original
    end
    subject.send_notifications(answer)
    # rubocop:enable RSpec/MessageSpies
  end
end
# rubocop:enable RSpec/NamedSubject
