# frozen_string_literal: true

require 'rails_helper'

feature 'User can delete files from question', %q(
  As an authenticated user
  I'd like to be able to delete own attached file
) do
  given(:user) { create(:user) }
  given(:new_user) { create(:user) }
  given(:question) { create(:question, :with_attachment, user: user) }

  describe 'Authenticated user', js: true do
    scenario 'delete file from own question' do
      sign_in(user)
      visit question_path(question)

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'Delete file'

      accept_confirm do
        click_link 'Delete file'
      end

      expect(page).not_to have_link 'rails_helper.rb'
      expect(page).to have_content 'Your file removed.'
    end

    scenario 'tries delete file the not own question' do
      sign_in(new_user)
      visit question_path(question)

      expect(page).to have_link 'rails_helper.rb'
      expect(page).not_to have_link 'Delete file'
    end
  end

  describe 'Unauthenticated user', js: true do
    scenario 'tries delete file from question' do
      visit question_path(question)

      expect(page).to have_link 'rails_helper.rb'
      expect(page).not_to have_link 'Delete file'
    end
  end
end
