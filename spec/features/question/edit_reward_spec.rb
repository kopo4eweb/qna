# frozen_string_literal: true

require 'rails_helper'

feature 'User can replace reward to question', %q(
  As an question's author
  I'd like to be able to replace reward for best answer
) do
  given!(:question) { create(:question) }

  describe 'Authenticated user', js: true do
    background do
      sign_in(question.user)
      visit questions_path

      click_on 'Edit question'

      fill_in 'Reward title', with: 'Add reward'
      attach_file 'Image', "#{Rails.root}/spec/files/reward.png"
      click_on 'Save'

      click_on 'Edit question'

      fill_in 'Reward title', with: 'Replace reward'
    end

    scenario 'replace reward' do
      attach_file 'Image', "#{Rails.root}/spec/files/reward-2.png"
      click_on 'Save'

      expect(page).to have_content 'Replace reward'
    end

    scenario 'replace reward with invalid file' do
      attach_file 'Image', "#{Rails.root}/spec/rails_helper.rb"
      click_on 'Save'

      expect(page).to have_content 'Reward image has an invalid content type'
    end
  end
end
