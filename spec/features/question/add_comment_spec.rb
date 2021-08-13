# frozen_string_literal: true

require 'rails_helper'

feature 'User can add comment to a question', %q(
  In order to help for a community
  As an authenticated user
  I'd like to be able to write comments for a questions
) do
  given!(:user_question) { create(:user) }
  given!(:user_answer) { create(:user) }
  given!(:user_first) { create(:user) }
  given!(:question) { create(:question, user: user_question) }

  background { create_list(:answer, 2, question: question, user: user_answer) }

  scenario 'Unauthenticated user tries to comment' do
    visit question_path(question)

    within(".question-#{question.id}") do
      expect(page).not_to have_link 'Add comment'
    end
  end

  describe 'Authenticated user', js: true do
    scenario 'adding comment to a question' do
      sign_in(user_first)
      visit question_path(question)

      within(".question-#{question.id}") do
        click_on 'Add comment'

        within(".comment-form-question-#{question.id}") do
          fill_in 'Text comment', with: 'Add new comment'
          click_on 'Public comment'
        end

        expect(page).to have_content 'Add new comment'
        expect(page).to have_content user_first.email
      end
    end

    describe 'multiple sessions' do
      scenario 'all users see new comment for question in real-time', js: true do
        Capybara.using_session('user') do
          sign_in(user_first)
          visit question_path(question)
        end

        Capybara.using_session('guest') do
          visit question_path(question)
        end

        Capybara.using_session('user') do
          within(".question-#{question.id}") do
            click_on 'Add comment'

            within(".comment-form-question-#{question.id}") do
              fill_in 'Text comment', with: 'Add new comment'
              click_on 'Public comment'
            end

            expect(page).to have_content 'Add new comment'
            expect(page).to have_content user_first.email
          end
        end

        Capybara.using_session('guest') do
          expect(page).to have_content 'Add new comment'
          expect(page).to have_content user_first.email
        end
      end
    end
  end
end
