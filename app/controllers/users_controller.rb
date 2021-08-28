# frozen_string_literal: true

class UsersController < ApplicationController
  authorize_resource

  def email
    @user = User.new
  end

  def set_email
    password = Devise.friendly_token[0, 20]

    user = User.create!(email: email_params[:email], password: password, password_confirmation: password)

    user.authorizations.create!(provider: session[:auth]['provider'], uid: session[:auth]['uid'])

    redirect_to root_path, alert: 'Account create! Please confirm your email!'
  end

  private

  def email_params
    params.require(:user).permit(:email)
  end
end
