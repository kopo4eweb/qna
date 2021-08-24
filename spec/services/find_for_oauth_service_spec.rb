# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/NamedSubject
RSpec.describe FindForOauthService do
  subject { described_class.new(auth) }

  let!(:user) { create(:user) }
  let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456') }

  context 'when user already has authorization' do
    it 'return the user' do
      user.authorizations.create(provider: 'facebook', uid: '123456')
      expect(subject.call).to eq user
    end
  end

  context 'when user has not authorization' do
    context 'when user already exists' do
      let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: user.email }) }

      it 'does not create new  user' do
        expect { subject.call }.not_to change(User, :count)
      end

      it 'creates authorization for user' do
        expect { subject.call }.to change(user.authorizations, :count).by(1)
      end

      it 'creates authorization with provider ans uid' do
        authorization = subject.call.authorizations.first

        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end

      it 'returns the user' do
        expect(subject.call).to eq user
      end
    end
  end

  context 'when user does not exist' do
    let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: 'new@user.com' }) }

    it 'creates new user' do
      expect { subject.call }.to change(User, :count).by(1)
    end

    it 'returns new user' do
      expect(subject.call).to be_a(User)
    end

    it 'fills user email' do
      user = subject.call
      expect(user.email).to eq auth.info.email
    end

    it 'creates authorization for user' do
      user = subject.call
      expect(user.authorizations).not_to be_empty
    end

    it 'creates authorization for user with provider and uid' do
      authorization = subject.call.authorizations.first

      expect(authorization.provider).to eq auth.provider
      expect(authorization.uid).to eq auth.uid
    end
  end
end
# rubocop:enable RSpec/NamedSubject
