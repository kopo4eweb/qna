# frozen_string_literal: true

require 'rails_helper'

feature 'User can create answer of question', %q(
  In order to help for a community
  As an authenticated user
  I'd like to be able to given on the questions
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  background do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'
  end

  scenario 'Authenticated user gives on answer on a question' do
    visit question_path(question)

    expect(page).to have_content 'New answer'
    fill_in 'Body', with: 'New answer for question'
    click_on 'Give an answer'

    expect(page).to have_content 'Add new answer'
  end

  scenario 'Authenticated user gives on answer on a question with errors' do
    visit question_path(question)

    expect(page).to have_content 'New answer'
    click_on 'Give an answer'

    expect(page).to have_content "Body can't be blank"
  end

  scenario 'Unauthenticated user tries gives on answer on a question' do
    click_on 'Sign out'

    visit question_path(question)

    expect(page).to have_content 'New answer'
    fill_in 'Body', with: 'New answer for question'
    click_on 'Give an answer'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
