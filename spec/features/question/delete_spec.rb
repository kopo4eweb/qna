# frozen_string_literal: true

require 'rails_helper'

feature 'User can delete own question', %q(
  As an authenticated user
  I'd like to be able to delete own questions
) do
  given(:user) { create(:user) }
  given(:new_user) { create(:user) }
  given(:question) { create(:question, user: user) }

  describe 'Authenticated user' do
    scenario 'deletes the own question' do
      sign_in(user)

      visit question_path(question)
      expect(page).to have_content 'MyString'

      click_on 'Delete question'

      expect(page).to have_content 'Question MyString delete.'
    end

    scenario 'tries delete the not own question' do
      sign_in(new_user)

      visit question_path(question)
      expect(page).not_to have_link 'Delete question'
    end
  end

  scenario 'Unauthenticated user tries delete a question' do
    visit question_path(question)
    expect(page).not_to have_link 'Delete question'
  end
end
