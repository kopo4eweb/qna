# frozen_string_literal: true

require 'rails_helper'

feature 'User can add links to answer', %q(
  In order to provide additional info to my answer
  As an answers's author
  I'd like to be able to add links
) do
  given(:user) { create(:user) }
  given!(:question) { create(:question) }
  given(:gist_url) { 'https://gist.github.com/kopo4eweb/ee186726f9a58f3f778888117d9f3701' }

  scenario 'User adds link when give an answer', js: true do
    sign_in(user)
    visit question_path(question)

    fill_in 'Body', with: 'New answer for question'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Give an answer'

    within '.answers' do
      expect(page).to have_link 'My gist', href: gist_url
    end
  end
end
