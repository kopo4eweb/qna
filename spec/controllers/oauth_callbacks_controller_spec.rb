# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OauthCallbacksController, type: :controller do
  before do
    # rubocop:disable RSpec/InstanceVariable
    @request.env['devise.mapping'] = Devise.mappings[:user]
    # rubocop:enable RSpec/InstanceVariable
  end

  shared_examples_for 'providers' do |provider|
    describe "#{provider} tests" do
      let(:oauth_data) do
        OmniAuth::AuthHash.new(provider: provider, uid: '123456', info: { email: 'user@test.com' })
      end
      let(:oauth_data_without_email) do
        OmniAuth::AuthHash.new(provider: provider, uid: '123456')
      end

      it 'find user from oauth data' do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)

        # rubocop:disable RSpec/MessageSpies
        expect(User).to receive(:find_for_oauth).with(oauth_data)
        # rubocop:enable RSpec/MessageSpies
        get provider.to_sym
      end

      context 'when user exists' do
        let!(:user) { create(:user) }

        before do
          allow(User).to receive(:find_for_oauth).and_return(user)
          get provider.to_sym
        end

        it 'login user' do
          expect(subject.current_user).to eq user
        end

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end
      end

      context 'when user does not exists' do
        before do
          allow(User).to receive(:find_for_oauth)
          get provider.to_sym
        end

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end

        it 'does not login user' do
          expect(subject.current_user).not_to be_an_instance_of(User)
        end
      end

      context "when user does not exist and responce don't have Email" do
        it 'redirect to email_url' do
          allow(request.env).to receive(:[]).and_call_original
          allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data_without_email)
          get provider.to_sym

          expect(response).to redirect_to email_url
        end
      end
    end
  end

  describe 'Github' do
    it_behaves_like 'providers', 'github'
  end

  describe 'VKontakte' do
    it_behaves_like 'providers', 'vkontakte'
  end
end
