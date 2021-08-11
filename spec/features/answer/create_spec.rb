# frozen_string_literal: true

require 'rails_helper'

feature 'User can create answer of question', %q(
  In order to help for a community
  As an authenticated user
  I'd like to be able to given on the questions
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  describe 'Authenticated user', js: true do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'gives on answer on a question' do
      expect(page).to have_content 'New answer'
      fill_in 'Body', with: 'New answer for question'
      click_on 'Give an answer'

      expect(page).to have_current_path question_path(question), ignore_query: true
      within '.answers' do
        expect(page).to have_content 'New answer for question'
      end
    end

    scenario 'gives on answer on a question with attached files' do
      fill_in 'Body', with: 'New answer for question'
      attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Give an answer'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end

    scenario 'gives on answer on a question with errors' do
      expect(page).to have_content 'New answer'
      click_on 'Give an answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  describe 'multiple sessions' do
    scenario 'all users see new answer in real-time', js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(question)
      end

      Capybara.using_session('user') do
        fill_in 'Body', with: 'New answer for question'
        click_on 'Give an answer'

        within '.answers' do
          expect(page).to have_content 'New answer for question'
        end
      end

      Capybara.using_session('guest') do
        within '.answers' do
          expect(page).to have_content 'New answer for question'
        end
      end
    end
  end

  scenario 'Unauthenticated user tries gives on answer on a question' do
    visit question_path(question)
    expect(page).not_to have_content 'New answer'
  end
end
