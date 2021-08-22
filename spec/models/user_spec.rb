# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:rewards) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_many(:authorizations).dependent(:destroy) }

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

  describe '.find_for_oauth' do
    let!(:user) { create(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456') }

    context 'when user already has authorization' do
      it 'return the user' do
        user.authorizations.create(provider: 'facebook', uid: '123456')
        expect(described_class.find_for_oauth(auth)).to eq user
      end
    end

    context 'when user has not authorization' do
      context 'when user already exists' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: user.email }) }

        it 'does not create new  user' do
          expect { described_class.find_for_oauth(auth) }.not_to change(described_class, :count)
        end

        it 'creates authorization for user' do
          expect { described_class.find_for_oauth(auth) }.to change(user.authorizations, :count).by(1)
        end

        it 'creates authorization with provider ans uid' do
          authorization = described_class.find_for_oauth(auth).authorizations.first

          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end

        it 'returns the user' do
          expect(described_class.find_for_oauth(auth)).to eq user
        end
      end
    end

    context 'when user does not exist' do
      let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: 'new@user.com' }) }

      it 'creates new user' do
        expect { described_class.find_for_oauth(auth) }.to change(described_class, :count).by(1)
      end

      it 'returns new user' do
        expect(described_class.find_for_oauth(auth)).to be_a(described_class)
      end

      it 'fills user email' do
        user = described_class.find_for_oauth(auth)
        expect(user.email).to eq auth.info.email
      end

      it 'creates authorization for user' do
        user = described_class.find_for_oauth(auth)
        expect(user.authorizations).not_to be_empty
      end

      it 'creates authorization for user with provider and uid' do
        authorization = described_class.find_for_oauth(auth).authorizations.first

        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end
    end
  end
end
