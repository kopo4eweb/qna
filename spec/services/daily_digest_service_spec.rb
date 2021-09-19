# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/NamedSubject
RSpec.describe DailyDigestService do
  let(:users) { create_list(:user, 3) }

  it 'sends daily digest to all users' do
    # rubocop:disable RSpec/MessageSpies
    users.each { |user| expect(DailyDigestMailer).to receive(:digest).with(user).and_call_original }
    # rubocop:enable RSpec/MessageSpies
    subject.send_digest
  end
end
# rubocop:enable RSpec/NamedSubject
