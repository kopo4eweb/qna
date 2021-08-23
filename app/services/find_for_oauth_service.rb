# frozen_string_literal: true

class FindForOauthService
  attr_reader :auth

  def initialize(auth)
    @auth = auth
  end

  def call
    authorization = Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
    return authorization.user if authorization

    email = auth.dig('info', 'email')
    user = User.find_by(email: email)

    if user
      create_authorization(user)
    elsif email
      password = Devise.friendly_token[0, 20]
      user = User.create!(
        email: email,
        password: password,
        password_confirmation: password,
        confirmed_at: Time.zone.now
      )
      create_authorization(user)
    end

    user
  end

  private

  def create_authorization(user)
    user.authorizations.create!(provider: auth.provider, uid: auth.uid.to_s)
  end
end
