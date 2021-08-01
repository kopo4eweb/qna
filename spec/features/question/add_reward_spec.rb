# frozen_string_literal: true

require 'rails_helper'

feature 'User can add reward to question', %q(
  As an question's author
  I'd like to be able to add reward for best answer
) do
  given(:user)      { create(:user) }
  given(:question)  { create(:question) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit questions_path

      click_on 'Ask question'

      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'text text text'

      fill_in 'Reward title', with: 'Add reward'
    end

    scenario 'add reward' do
      attach_file 'Image', "#{Rails.root}/spec/files/reward.png"

      click_on 'Ask'

      visit questions_path
      expect(page).to have_content 'Add reward'
    end

    scenario 'add reward with invalid file' do
      attach_file 'Image', "#{Rails.root}/spec/rails_helper.rb"

      click_on 'Ask'

      expect(page).to have_content 'Reward image has an invalid content type'
    end
  end
end
