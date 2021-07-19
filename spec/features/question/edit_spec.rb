# frozen_string_literal: true

require 'rails_helper'

feature 'User can edit his question', %q(
  In order to correct mistakes
  As an author of question
  I'd like to be able to edit my question
) do
  given(:user) { create(:user) }
  given!(:question) { create(:question) }

  scenario 'Unauthenticated can not edit answer' do
    visit questions_path

    expect(page).not_to have_link 'Edit question'
  end

  describe 'Authenticated user', js: true do
    scenario 'edit his question' do
      sign_in(question.user)
      visit questions_path

      click_on 'Edit question'

      fill_in 'Title', with: 'My edit question'
      fill_in 'Body', with: 'My edit text'
      click_on 'Save'

      expect(page).not_to have_content question.title
      expect(page).not_to have_content question.body
      expect(page).to have_content 'My edit question'
      expect(page).to have_content 'My edit text'
      expect(page).not_to have_selector 'textarea'
    end

    scenario 'open and cancel edit his question' do
      sign_in(question.user)
      visit questions_path

      click_on 'Edit question'

      fill_in 'Title', with: 'My edit question'
      fill_in 'Body', with: 'My edit text'
      click_on 'Cancel'

      expect(page).to have_content question.title
      expect(page).to have_content question.body
      expect(page).not_to have_content 'My edit question'
      expect(page).not_to have_content 'My edit text'
      expect(page).not_to have_selector 'textarea'
    end

    scenario 'edit his question with errors' do
      sign_in(question.user)
      visit questions_path

      click_on 'Edit question'

      fill_in 'Title', with: ''
      fill_in 'Body', with: ''
      click_on 'Save'

      expect(page).to have_content "Title can't be blank"
      expect(page).to have_content "Body can't be blank"
    end

    scenario "tries to edit other user's question" do
      sign_in(user)
      visit questions_path

      expect(page).not_to have_link 'Edit question'
    end
  end
end
