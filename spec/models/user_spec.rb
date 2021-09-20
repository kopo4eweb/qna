# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:rewards) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:subscriptions).dependent(:destroy) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe 'Check author' do
    let(:user) { create(:user) }
    let(:author_question) { create(:question, user: user) }
    let(:question) { create(:question) }

    describe 'a question' do
      it 'current user is an author' do
        expect(user).to be_author_of(author_question)
      end

      it "current user isn't an author" do
        expect(user).not_to be_author_of(question)
      end
    end
  end

  describe 'Check voted' do
    let!(:user) { create(:user) }
    let!(:new_user) { create(:user) }

    let!(:question) { create(:question, user: new_user) }
    let!(:new_question) { create(:question, user: user) }

    it 'user has been vote' do
      create(:vote, user: user, votable: question)
      expect(user).to be_voted(question)
    end

    it 'user has not been vote' do
      expect(user).not_to be_voted(new_question)
    end
  end

  describe 'Check subscribe' do
    let!(:user) { create(:user) }
    let!(:question) { create(:question) }
    let!(:new_question) { create(:question) }

    it 'subscription user' do
      create(:subscription, user: user, question: question)
      expect(user).to be_subscribed(question)
    end

    it 'unsubscription user' do
      expect(user).not_to be_subscribed(new_question)
    end
  end

  # rubocop:disable RSpec/MessageSpies
  # rubocop:disable RSpec/VerifiedDoubles
  # rubocop:disable RSpec/StubbedMock
  describe '.find_for_oauth' do
    let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456') }
    let(:service) { double('FindForOauthService') }

    it 'calls FindForOauthService' do
      expect(FindForOauthService).to receive(:new).with(auth).and_return(service)
      expect(service).to receive(:call)
      described_class.find_for_oauth(auth)
    end
  end
  # rubocop:enable RSpec/MessageSpies
  # rubocop:enable RSpec/VerifiedDoubles
  # rubocop:enable RSpec/StubbedMock
end
