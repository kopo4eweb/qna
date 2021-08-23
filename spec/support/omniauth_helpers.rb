# frozen_string_literal: true

module OmniauthHelpers
  OmniAuth.config.test_mode = true

  def mock_auth_hash(provider, email:)
    OmniAuth.config.mock_auth[provider.to_sym] = OmniAuth::AuthHash.new(
      provider: provider.to_sym,
      uid: '123456',
      info: {
        email: email
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    )
  end

  def invalid_mock(provider)
    OmniAuth.config.mock_auth[provider.to_sym] = :invalid_credentials
  end
end
