# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can edit his question', %q(
  In order to correct mistakes
  As an author of question
  I'd like to be able to edit my question
) do
  given(:user) { create(:user) }
  given!(:question) { create(:question) }
  given(:google_url) { 'https://google.com' }

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

    scenario 'can add files while edit his question' do
      sign_in(question.user)
      visit questions_path

      click_on 'Edit question'

      attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Save'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end

    scenario 'can add link while edit his question' do
      sign_in(question.user)
      visit questions_path

      click_on 'Edit question'

      click_on 'Add link'

      within('.questions') do
        fill_in 'Link name', with: 'My google'
        fill_in 'Url', with: google_url
        click_on 'Save'
      end

      visit question_path(question)
      expect(page).to have_link 'My google', href: google_url
    end

    scenario 'can remove link while edit his question' do
      sign_in(question.user)
      visit questions_path
      click_on 'Edit question'

      click_on 'Add link'

      within('.questions') do
        fill_in 'Link name', with: 'My google'
        fill_in 'Url', with: google_url
        click_on 'Save'
      end

      visit question_path(question)
      expect(page).to have_link 'My google', href: google_url

      visit questions_path
      click_on 'Edit question'

      within('.questions') do
        click_on 'Remove link'
        click_on 'Save'
      end

      visit question_path(question)
      expect(page).not_to have_link 'My google'
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

  describe 'multiple sessions' do
    scenario 'all users see update question in real-time', js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit questions_path

        click_on 'Ask question'

        fill_in 'Title', with: 'Test question'
        fill_in 'Body', with: 'text text text'
        click_on 'Ask'

        expect(page).to have_content 'Your question successfully created.'
        expect(page).to have_content 'Test question'
        expect(page).to have_content 'text text text'
      end

      Capybara.using_session('guest') do
        visit questions_path

        expect(page).to have_content 'Test question'
        expect(page).to have_content 'text text text'
      end

      Capybara.using_session('user') do
        visit questions_path
        click_on 'Edit question'

        fill_in 'Title', with: 'Test question upadted'
        fill_in 'Body', with: 'text text text upadted'
        click_on 'Save'

        expect(page).to have_content 'Test question upadted'
        expect(page).to have_content 'text text text upadted'
      end

      Capybara.using_session('guest') do
        expect(page).to have_content 'Test question upadted'
        expect(page).to have_content 'text text text upadted'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
