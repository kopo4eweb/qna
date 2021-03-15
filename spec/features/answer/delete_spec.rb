# frozen_string_literal: true

require 'rails_helper'

feature 'User can delete own answer', %q(
  As an authenticated user
  I'd like to be able to delete own answer
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer) }

  describe 'Authenticated user' do
    scenario 'deletes the own answer' do
      sign_in(answer.user)
      visit question_path(answer.question)

      expect(page).to have_content answer.body

      click_on 'Delete answer'

      expect(page).to have_current_path question_path(answer.question)
      expect(page).not_to have_content answer.body
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
