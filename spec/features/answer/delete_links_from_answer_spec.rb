# frozen_string_literal: true

require 'rails_helper'

feature 'User can delete links from answer', %q(
  As an authenticated user
  I'd like to be able to delete own added links
) do
  given(:user) { create(:user) }
  given(:new_user) { create(:user) }
  given(:answer) { create(:answer, :with_links, user: user) }

  describe 'Authenticated user', js: true do
    scenario 'delete link from own answer' do
      sign_in(answer.user)
      visit question_path(answer.question)

      expect(page).to have_link 'google'
      expect(page).to have_link 'Delete link'

      accept_confirm do
        click_link 'Delete link'
      end

      expect(page).not_to have_link 'google'
      expect(page).to have_content 'Your link removed.'
    end

    scenario 'tries delete link the not own answer' do
      sign_in(new_user)
      visit question_path(answer.question)

      expect(page).to have_link 'google'
      expect(page).not_to have_link 'Delete link'
    end
  end

  describe 'Unauthenticated user', js: true do
    scenario 'tries delete link from answer' do
      visit question_path(answer.question)

      expect(page).to have_link 'google'
      expect(page).not_to have_link 'Delete link'
    end
  end
end
