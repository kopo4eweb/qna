# frozen_string_literal: true

require 'rails_helper'

feature 'User can delete own answer', %q(
  As an authenticated user
  I'd like to be able to delete own answer
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer) }

  describe 'Authenticated user', js: true do
    scenario 'deletes the own answer' do
      sign_in(answer.user)
      visit question_path(answer.question)

      expect(page).to have_content answer.body

      accept_confirm do
        click_link 'Delete answer'
      end

      within '.answers' do
        expect(page).not_to have_content answer.body
        expect(page).not_to have_link 'Delete answer'
        expect(page).to have_content 'Your answer removed.'
      end
    end

    scenario 'tries delete the not own answer' do
      sign_in(user)
      visit question_path(answer.question)

      expect(page).to have_content answer.body
      expect(page).not_to have_link 'Delete answer'
    end
  end

  describe 'multiple sessions' do
    scenario 'all users see new answer in real-time', js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
        fill_in 'Body', with: 'New answer for question'
        click_on 'Give an answer'

        within '.answers' do
          expect(page).to have_content 'New answer for question'
        end
      end

      Capybara.using_session('guest') do
        visit question_path(question)

        within '.answers' do
          expect(page).to have_content 'New answer for question'
        end
      end

      Capybara.using_session('user') do
        accept_confirm do
          click_link 'Delete answer'
        end

        expect(page).to have_content 'Your answer removed.'
      end

      Capybara.using_session('guest') do
        expect(page).not_to have_content 'New answer for question'
      end
    end
  end

  scenario 'Unauthenticated user tries delete a answer' do
    visit question_path(answer.question)

    expect(page).to have_content answer.body
    expect(page).not_to have_link 'Delete answer'
  end
end
