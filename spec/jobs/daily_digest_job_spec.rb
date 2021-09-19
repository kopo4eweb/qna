# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyDigestJob, type: :job do
  # rubocop:disable RSpec/VerifiedDoubles
  let(:service) { double('DailyDigestService') }
  # rubocop:enable RSpec/VerifiedDoubles

  before do
    allow(DailyDigestService).to receive(:new).and_return(service)
  end

  it 'cals DailyDigestService#send_digest' do
    # rubocop:disable RSpec/MessageSpies
    expect(service).to receive(:send_digest)
    # rubocop:enable RSpec/MessageSpies
    described_class.perform_now
  end
end
