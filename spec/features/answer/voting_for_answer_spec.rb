# frozen_string_literal: true

require 'rails_helper'

feature 'User can to voting a answer', %q(
  As an any user
  I'd like to be able to vote for the answer me like
) do
  given!(:user_question) { create(:user) }
  given!(:user_answer) { create(:user) }
  given!(:user_first) { create(:user) }
  given!(:user_second) { create(:user) }
  given!(:question) { create(:question, user: user_question) }
  given!(:answers) { create_list(:answer, 4, question: question, user: user_answer) }

  scenario 'Unauthenticated user tries to vote' do
    visit question_path(question)

    within("#vote-answer-#{answers[0].id}") do
      expect(page).not_to have_link 'up'
      expect(page).not_to have_link 'down'
      expect(page).not_to have_link 'cancel vote'
    end
  end

  describe 'Authenticated user', js: true do
    scenario 'vote Up a answer' do
      sign_in(user_first)
      visit question_path(question)

      within("#vote-answer-#{answers[1].id}") do
        click_on 'up'

        expect(page).not_to have_content 'up'
        expect(page).to have_link 'cancel vote'
        within('.vote-result') { expect(page).to have_content('1') }
      end
    end

    scenario 'vote Down a answer' do
      sign_in(user_second)
      visit question_path(question)

      within("#vote-answer-#{answers[0].id}") do
        click_on 'down'

        expect(page).not_to have_content 'down'
        expect(page).to have_link 'cancel vote'
        within('.vote-result') { expect(page).to have_content('-1') }
      end
    end

    scenario 'cancel vote a answer' do
      sign_in(user_first)
      visit question_path(question)

      within("#vote-answer-#{answers[2].id}") do
        click_on 'up'

        expect(page).not_to have_link 'up'
        within('.vote-result') { expect(page).to have_content('1') }

        expect(page).to have_link 'cancel vote'
        click_on 'cancel vote'
        within('.vote-result') { expect(page).to have_content('0') }
      end
    end

    scenario 'cancel vote and set new vote a answer' do
      sign_in(user_second)
      visit question_path(question)

      within("#vote-answer-#{answers[1].id}") do
        click_on 'down'
        within('.vote-result') { expect(page).to have_content('-1') }

        click_on 'cancel vote'
        within('.vote-result') { expect(page).to have_content('0') }

        click_on 'up'
        within('.vote-result') { expect(page).to have_content('1') }
      end
    end

    scenario 'tries to vote own answer' do
      sign_in(user_answer)
      visit question_path(question)

      within("#vote-answer-#{answers[0].id}") do
        expect(page).not_to have_link 'up'
        expect(page).not_to have_link 'down'
        expect(page).not_to have_link 'cancel vote'
        within('.vote-result') { expect(page).to have_content('0') }
      end
    end

    scenario 'some users voting a answer' do
      sign_in(user_first)
      visit question_path(question)
      within("#vote-answer-#{answers[2].id}") do
        click_on 'up'
        within('.vote-result') { expect(page).to have_content('1') }
      end

      sign_out(user_first)

      sign_in(user_second)
      visit question_path(question)
      within("#vote-answer-#{answers[2].id}") do
        click_on 'up'
        within('.vote-result') { expect(page).to have_content('2') }
      end

      sign_out(user_second)

      sign_in(user_first)
      visit question_path(question)
      within("#vote-answer-#{answers[2].id}") do
        click_on 'cancel vote'
        within('.vote-result') { expect(page).to have_content('1') }
      end
    end
  end
end
