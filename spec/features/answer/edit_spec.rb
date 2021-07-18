# frozen_string_literal: true

require 'rails_helper'

feature 'User can edit his answer', %q(
  In order to correct mistakes
  As an author of answer
  I'd like to be able to edit my answer
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer) }

  scenario 'Unauthenticated can not edit answer' do
    visit question_path(question)

    expect(page).not_to have_link 'Edit answer'
  end

  describe 'Authenticated user', js: true do
    scenario 'edit his answer' do
      sign_in(answer.user)
      visit question_path(answer.question)

      click_on 'Edit answer'

      within '.answers' do
        fill_in 'Body', with: 'edited answer'
        click_on 'Save'

        expect(page).not_to have_content answer.body
        expect(page).to have_content 'edited answer'
        expect(page).not_to have_selector 'textarea'
      end
    end

    scenario 'create and edit this answer' do
      sign_in(user)
      visit question_path(question)

      expect(page).to have_content 'New answer'
      fill_in 'Body', with: 'New answer for question'
      click_on 'Give an answer'

      expect(page).to have_current_path question_path(question), ignore_query: true

      within '.answers' do
        expect(page).to have_content 'New answer for question'

        click_on 'Edit answer'

        fill_in 'Body', with: 'edited answer'
        click_on 'Save'

        expect(page).not_to have_content 'New answer for question'
        expect(page).to have_content 'edited answer'
        expect(page).not_to have_selector 'textarea'
      end
    end

    scenario 'open and cancel edit his answer' do
      sign_in(answer.user)
      visit question_path(answer.question)

      click_on 'Edit answer'

      within '.answers' do
        fill_in 'Body', with: 'edited answer'
        click_on 'Cancel'

        expect(page).to have_content answer.body
        expect(page).not_to have_content 'edited answer'
        expect(page).not_to have_selector 'textarea'
      end
    end

    scenario 'edit his answer with errors' do
      sign_in(answer.user)
      visit question_path(answer.question)

      click_on 'Edit answer'

      within '.answers' do
        fill_in 'Body', with: ''
        click_on 'Save'

        expect(page).to have_content "Body can't be blank"
      end
    end

    scenario "tries to edit other user's answer" do
      sign_in(user)
      visit question_path(answer.question)

      expect(page).not_to have_link 'Edit answer'
    end
  end
end
