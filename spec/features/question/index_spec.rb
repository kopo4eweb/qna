# frozen_string_literal: true

require 'rails_helper'

feature 'User can view all question', %q(
  In order to get answer from a community
  As an any user
  I'd like to be able to look the all questions
) do
  scenario 'the all questions' do
    questions = create_list(:question, 2)

    visit questions_path

    expect(page).to have_content 'List question'

    expect(page).to have_content questions[0].title
    expect(page).to have_content questions[0].body

    expect(page).to have_content questions[1].title
    expect(page).to have_content questions[1].body
  end
end
