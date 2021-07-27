# frozen_string_literal: true

require 'rails_helper'

feature 'User can add links to question', %q(
  In order to provide additional info to my question
  As an question's author
  I'd like to be able to add links
) do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/kopo4eweb/ee186726f9a58f3f778888117d9f3701' }
  given(:bad_url) { 'bad_url.org' }

  background do
    sign_in(user)
    visit new_question_path

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'text text text'

    fill_in 'Link name', with: 'My gist'
  end

  scenario 'User adds link when asks question' do
    fill_in 'Url', with: gist_url

    click_on 'Ask'

    expect(page).to have_link 'My gist', href: gist_url
  end

  scenario 'User adds link when asks question with error' do
    fill_in 'Url', with: bad_url

    click_on 'Ask'

    expect(page).to have_content 'Links url is not a valid URL'
    expect(page).not_to have_link 'My gist', href: bad_url
  end
end
