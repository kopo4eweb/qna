# frozen_string_literal: true

require 'rails_helper'

feature 'User can to look a question and answers for it', %q(
  In order to get answer from a community
  As an any user
  I'd like to be able to look the question and answers for it
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  scenario 'show question and answers' do
    answers = create_list(:answer, 3, question: question)

    visit question_path(question)

    expect(page).to have_content 'Question title'
    expect(page).to have_content 'Answer'

    expect(page).to have_content answers[0].body
    expect(page).to have_content answers[1].body
    expect(page).to have_content answers[2].body
  end
end
