# frozen_string_literal: true

class OauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    # connect_to('GitHub')
    # render json: request.env['omniauth.auth']

    @user = User.find_for_oauth(request.env['omniauth.auth'])

    if @user&.persisted?
      sign_in_and_redirect @user, event: :authenticate
      set_flash_message(:notice, :success, kind: 'GitHub') if is_navigational_format?
    else
      redirect_to root_path, alert: 'User not found'
    end
  end

  private

  def connect_to(provider)
    auth = request.env['omniauth.auth']
    @user = FindForOauthService.new(auth).call

    if @user&.persisted?
      sign_in_and_redirect @user, event: :authenticate
      set_flash_message(:notice, :success, kind: provider.to_s) if is_navigational_format?
    elsif auth != :invalid_credential && !auth.nil?
      session[:auth] = auth.except('extra')
      redirect_to get_email_url, alert: 'We don`t found you email, please register and fill it!'
    else
      redirect_to root_path, alert: 'Something went wrong'
    end
  end
end
