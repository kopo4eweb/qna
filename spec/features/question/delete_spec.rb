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

  describe 'multiple sessions' do
    scenario 'all users see delete question in real-time', js: true do
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

        click_on 'Detail'

        accept_confirm do
          click_on 'Delete question'
        end

        expect(page).to have_content 'Question Test question delete'
      end

      Capybara.using_session('guest') do
        expect(page).not_to have_content 'Test question'
        expect(page).not_to have_content 'text text text'
      end
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
