# frozen_string_literal: true

require 'rails_helper'

feature 'User can add links to question', %q(
  In order to provide additional info to my question
  As an question's author
  I'd like to be able to add links
) do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/kopo4eweb/ee186726f9a58f3f778888117d9f3701' }
  given(:google_url) { 'https://google.com' }
  given(:bad_url) { 'bad_url.org' }

  describe 'User when asks question adds links with', js: true do
    background do
      sign_in(user)
      visit new_question_path

      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'text text text'
    end

    scenario 'simple url' do
      fill_in 'Link name', with: 'My google'
      fill_in 'Url', with: google_url

      click_on 'Ask'

      expect(page).to have_link 'My google', href: google_url
    end

    scenario 'gist url with loading content on a page' do
      fill_in 'Link name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'Ask'

      expect(page).to have_link 'My gist', href: gist_url
      expect(page).to have_content 'test_guru_question.txt'
    end

    scenario 'with url error' do
      fill_in 'Link name', with: 'Bad url'
      fill_in 'Url', with: bad_url

      click_on 'Ask'

      expect(page).to have_content 'Links url is not a valid URL'
      expect(page).not_to have_link 'Bad url', href: bad_url
    end
  end
end
