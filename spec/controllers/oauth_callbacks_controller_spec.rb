# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OauthCallbacksController, type: :controller do
  before do
    # rubocop:disable RSpec/InstanceVariable
    @request.env['devise.mapping'] = Devise.mappings[:user]
    # rubocop:enable RSpec/InstanceVariable
  end

  describe 'GitHub' do
    let(:oauth_data) { { 'provider' => 'github', 'uid' => 123 } }

    it 'find user from oauth data' do
      allow(request.env).to receive(:[]).and_call_original
      allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)

      # rubocop:disable RSpec/MessageSpies
      expect(User).to receive(:find_for_oauth).with(oauth_data)
      # rubocop:enable RSpec/MessageSpies
      get :github
    end

    context 'when user exists' do
      let!(:user) { create(:user) }

      before do
        allow(User).to receive(:find_for_oauth).and_return(user)
        get :github
      end

      # rubocop:disable RSpec/NamedSubject
      it 'login user' do
        expect(subject.current_user).to eq user
      end
      # rubocop:enable RSpec/NamedSubject

      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'when user does not exists' do
      before do
        allow(User).to receive(:find_for_oauth)
        get :github
      end

      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end

      # rubocop:disable RSpec/NamedSubject
      it 'does not login user' do
        expect(subject.current_user).not_to be_an_instance_of(User)
      end
      # rubocop:enable RSpec/NamedSubject
    end
  end
end
