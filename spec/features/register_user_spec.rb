# frozen_string_literal: true

require 'rails_helper'

feature 'User can registered in system', %q(
  In order to ask questions
  As an authenticated user
  I'd like to be able to registered in system
) do
  background { visit new_user_registration_path }

  describe 'New user tries to registration' do
    scenario 'with valid' do
      fill_in 'Email', with: 'user@test.com'
      fill_in 'Password', with: '12345678'
      fill_in 'Password confirmation', with: '12345678'
      click_on 'Sign up'

      expect(page).to have_content 'Welcome! You have signed up successfully.'
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

    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_on 'Sign up'

    expect(page).to have_content 'Email has already been taken'
  end
end
