# frozen_string_literal: true

require 'rails_helper'

feature 'User can registered in system', %q(
  In order to ask questions
  As an authenticated user
  I'd like to be able to registered in system
) do
  describe 'New user tries to registration' do
    background { visit new_user_registration_path }

    scenario 'with valid' do
      fill_in 'Email', with: 'user@test.com'
      fill_in 'Password', with: '12345678'
      fill_in 'Password confirmation', with: '12345678'
      click_on 'Sign up'

      open_email('user@test.com')
      current_email.click_on 'Confirm my account'

      fill_in 'Email', with: 'user@test.com'
      fill_in 'Password', with: '12345678'
      click_on 'Log in'
      expect(page).to have_content 'Signed in successfully.'
    end

    describe 'with invalid' do
      scenario 'email' do
        fill_in 'Email', with: 'user'
        fill_in 'Password', with: '12345678'
        fill_in 'Password confirmation', with: '12345678'
        click_on 'Sign up'

        expect(page).to have_content 'Email is invalid'
      end

      describe 'password' do
        scenario 'blank' do
          fill_in 'Email', with: 'user@test.com'
          fill_in 'Password', with: ''
          fill_in 'Password confirmation', with: ''
          click_on 'Sign up'

          expect(page).to have_content "Password can't be blank"
        end

        scenario 'less than 6' do
          fill_in 'Email', with: 'user@test.com'
          fill_in 'Password', with: '12345'
          fill_in 'Password confirmation', with: '12345'
          click_on 'Sign up'

          expect(page).to have_content 'Password is too short (minimum is 6 characters)'
        end
      end

      scenario 'confirmation password' do
        fill_in 'Email', with: 'user@test.com'
        fill_in 'Password', with: '12345678'
        fill_in 'Password confirmation', with: '1234567890'
        click_on 'Sign up'

        expect(page).to have_content "Password confirmation doesn't match Password"
      end
    end
  end

  scenario 'Do not register an existing user in the system' do
    User.create!(email: 'user@test.com', password: '12345678')

    visit new_user_registration_path
    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_on 'Sign up'

    expect(page).to have_content 'Email has already been taken'
  end

  describe 'Register with Omniauth services' do
    describe 'GitHub' do
      scenario 'with correct data' do
        mock_auth_hash('github', email: 'user@test.com')
        visit new_user_registration_path
        click_link 'Sign in with GitHub'

        expect(page).to have_content 'Successfully authenticated from GitHub account.'
      end

      scenario 'can handle authentication error with GitHub' do
        invalid_mock('github')
        visit new_user_registration_path
        click_link 'Sign in with GitHub'
        expect(page).to have_content 'Could not authenticate you from GitHub because "Invalid credentials"'
      end
    end

    describe 'Vkontakte' do
      scenario 'with correct data, without email' do
        mock_auth_hash('Vkontakte', email: nil)
        visit new_user_registration_path
        click_link 'Sign in with Vkontakte'
        fill_in 'user_email', with: 'user@test.com'
        click_on 'Send confirmation to email'

        open_email('user@test.com')
        current_email.click_link 'Confirm my account'
        click_link 'Sign in with Vkontakte'

        expect(page).to have_content 'Successfully authenticated from Vkontakte account.'
      end

      scenario 'can handle authentication error with Vkontakte' do
        invalid_mock('vkontakte')
        visit new_user_registration_path
        click_link 'Sign in with Vkontakte'

        expect(page).to have_content 'Could not authenticate you from Vkontakte because "Invalid credentials"'
      end
    end
  end
end
