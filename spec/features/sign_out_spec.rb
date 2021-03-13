# frozen_string_literal: true

require 'rails_helper'

feature 'User can sign out', %q(
  As an authenticated user
  I'd like to be able to sign out of system
) do
  given(:user) { create(:user) }

  background { sign_in(user) }

  scenario 'Registered user tries to sign out' do
    expect(page).to have_content 'Signed in successfully.'

    click_on 'Sign out'
    expect(page).to have_content 'Signed out successfully.'
  end
end
