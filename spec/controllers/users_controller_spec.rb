# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #email' do
    it 'assigns the requested user to @user' do
      get :email
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #set_email' do
    let!(:auth) { { 'provider' => 'Provider', 'uid' => '123456' } }

    before { session[:auth] = auth }

    it 'create new user' do
      expect { post :set_email, params: { user: attributes_for(:user) } }.to change(User, :count).by(1)
    end

    it 'create new authorization' do
      expect { post :set_email, params: { user: attributes_for(:user) } }.to change(Authorization, :count).by(1)
    end

    it 'redirect to root' do
      post :set_email, params: { user: attributes_for(:user) }
      expect(response).to redirect_to root_path
    end
  end
end
