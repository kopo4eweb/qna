# frozen_string_literal: true

require 'rails_helper'

feature 'User can choose best answer', %q(
  In order to select best answer for a community
  As an authenticated user
  I'd like to be able to select the best answer
) do
  given(:user) { create(:user) }
  given(:new_user) { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:first_answer) { create(:answer, question: question, user: user) }
  given!(:second_answer) { create(:answer, question: question, user: user) }

  scenario 'Unauthenticated can not choose best answer' do
    visit question_path(question)
    expect(page).not_to have_link 'Make it best'
  end

  describe 'Authenticated user choose best answer' do
    scenario 'the own question', js: true do
      sign_in(user)
      visit question_path(question)

      within ".answer-#{first_answer.id}" do
        click_on 'Make it best'
        expect(page).to have_css '.best_answer_of_question'
        expect(page).to have_content 'Best answer!'
      end

      within ".answer-#{second_answer.id}" do
        expect(page).not_to have_content 'Best answer!'
        click_on 'Make it best'
        expect(page).to have_css '.best_answer_of_question'
        expect(page).to have_content 'Best answer!'
      end

      within ".answer-#{first_answer.id}" do
        expect(page).not_to have_css '.best_answer_of_question'
        expect(page).not_to have_content 'Best answer!'
      end

      within '.answers' do
        expect(page.body).to match(/answer-#{second_answer.id}.*answer-#{first_answer.id}/)
      end
    end

    scenario 'the not own question', js: true do
      sign_in(new_user)
      visit question_path(question)
      expect(page).not_to have_link 'Make it best'
    end
  end
end
