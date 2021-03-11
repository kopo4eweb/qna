# frozen_string_literal: true

require 'rails_helper'

feature 'User can to look a question and answers for it', %q(
  In order to get answer from a community
  As an any user
  I'd like to be able to look the question and answers for it
) do
  given(:question) { create(:question) }

  scenario 'show question and answers' do
    create(:answer, question: question)

    visit question_path(question)

    expect(page).to have_content 'MyString'
    expect(page).to have_content 'MyText'

    expect(page).to have_content 'MyText Answer'
  end
end
