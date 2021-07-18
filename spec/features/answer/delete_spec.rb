# frozen_string_literal: true

require 'rails_helper'

feature 'User can delete own answer', %q(
  As an authenticated user
  I'd like to be able to delete own answer
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer) }

  describe 'Authenticated user', js: true do
    scenario 'deletes the own answer' do
      sign_in(answer.user)
      visit question_path(answer.question)

      expect(page).to have_content answer.body

      accept_confirm do
        click_link 'Delete answer'
      end

      within '.answers' do
        expect(page).not_to have_content answer.body
        expect(page).not_to have_link 'Delete answer'
        expect(page).to have_content 'Your answer removed.'
      end
    end

    scenario 'tries delete the not own answer' do
      sign_in(user)
      visit question_path(answer.question)

      expect(page).to have_content answer.body
      expect(page).not_to have_link 'Delete answer'
    end
  end

  scenario 'Unauthenticated user tries delete a answer' do
    visit question_path(answer.question)

    expect(page).to have_content answer.body
    expect(page).not_to have_link 'Delete answer'
  end
end
