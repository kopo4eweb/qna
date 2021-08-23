# frozen_string_literal: true

class OauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    connect_to('GitHub')
  end

  def vkontakte
    connect_to('Vkontakte')
  end

  private

  def connect_to(provider)
    auth = request.env['omniauth.auth']
    @user = User.find_for_oauth(auth)

    if @user&.persisted?
      sign_in_and_redirect @user, event: :authenticate
      set_flash_message(:notice, :success, kind: provider.to_s) if is_navigational_format?
    elsif auth != :invalid_credential && !auth.nil?
      session[:auth] = auth.except('extra')
      redirect_to email_url, alert: 'Your email not found, you need register with set email.'
    else
      redirect_to root_path, alert: 'Something went wrong. Please try again later.'
    end
  end
end
