# frozen_string_literal: true

require 'rails_helper'

feature 'User can delete own question', %q(
  As an authenticated user
  I'd like to be able to delete own questions
) do
  given(:user) { create(:user) }
  given(:new_user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer, question: question) }

  describe 'Authenticated user' do
    scenario 'deletes the own question' do
      sign_in(question.user)
      visit question_path(answer.question)

      expect(page).to have_content question.title
      expect(page).to have_content question.body

      expect(page).to have_content answer.body

      click_on 'Delete question'

      expect(page).to have_content "Question #{question.title} delete."
    end

    scenario 'tries delete the not own question' do
      sign_in(new_user)

      visit question_path(answer.question)
      expect(page).to have_content question.title
      expect(page).to have_content question.body

      expect(page).to have_content answer.body

      expect(page).not_to have_link 'Delete question'
    end
  end

  scenario 'Unauthenticated user tries delete a question' do
    visit question_path(answer.question)
    expect(page).to have_content question.title
    expect(page).to have_content question.body

    expect(page).to have_content answer.body

    expect(page).not_to have_link 'Delete question'
  end
end
