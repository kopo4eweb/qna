# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationJob, type: :job do
  # rubocop:disable RSpec/VerifiedDoubles
  let(:service) { double('NotificationService') }
  let(:answer) { double('Answer') }
  # rubocop:enable RSpec/VerifiedDoubles

  before do
    allow(NotificationService).to receive(:new).and_return(service)
  end

  it 'calls NotificationService#send_notifications' do
    # rubocop:disable RSpec/MessageSpies
    expect(service).to receive(:send_notifications).with(answer)
    # rubocop:enable RSpec/MessageSpies
    described_class.perform_now(answer)
  end
end
