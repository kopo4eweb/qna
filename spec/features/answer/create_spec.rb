# frozen_string_literal: true

require 'rails_helper'

feature 'User can create answer of question', %q(
  In order to help for a community
  As an any user
  I'd like to be able to given on the questions
) do
  given(:question) { create(:question) }

  scenario 'user gives on answer on a question' do
    visit question_path(question)

    expect(page).to have_content 'New answer'
    fill_in 'Body', with: 'New answer'
    click_on 'Give an answer'

    expect(page).to have_content 'Add new answer'
  end

  scenario 'user gives on answer on a question with errors' do
    visit question_path(question)

    expect(page).to have_content 'New answer'
    click_on 'Give an answer'

    expect(page).to have_content "Body can't be blank"
  end
end
