# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Link, type: :model do
  it { should belong_to :linkable }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url }
  it { should validate_url_of :url }

  describe 'Check gist' do
    let(:gist_link) { create(:link, url: 'https://gist.github.com/kopo4eweb/ee186726f9a58f3f778888117d9f3701') }
    let(:not_gist_link) { create(:link) }

    it 'link is gist' do
      expect(gist_link).to be_gist
    end

    it 'link is not gist' do
      expect(not_gist_link).not_to be_gist
    end
  end
end
