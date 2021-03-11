# frozen_string_literal: true

require 'rails_helper'

feature 'User can sign out', %q(
  As an authenticated user
  I'd like to be able to sign out of system
) do
  given(:user) { User.create!(email: 'user@test.com', password: '12345678') }

  background { visit new_user_session_path }

  scenario 'Registered user tries to sign out' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'

    expect(page).to have_content 'Signed in successfully.'

    click_on 'Sign out'
    expect(page).to have_content 'Signed out successfully.'
  end
end
