# frozen_string_literal: true

require 'rails_helper'

feature 'User can create answer of question', %q(
  In order to help for a community
  As an authenticated user
  I'd like to be able to given on the questions
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'gives on answer on a question' do
      expect(page).to have_content 'New answer'
      fill_in 'Body', with: 'New answer for question'
      click_on 'Give an answer'

      expect(page).to have_content 'Add new answer'
    end

    scenario 'gives on answer on a question with errors' do
      expect(page).to have_content 'New answer'
      click_on 'Give an answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries gives on answer on a question' do
    visit question_path(question)
    expect(page).not_to have_content 'New answer'
  end
end
