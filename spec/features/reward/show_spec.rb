# frozen_string_literal: true

require 'rails_helper'

feature 'User can to look own rewards of best answers', %q(
  I'd like to be able to look the rewards of my answers
) do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  describe 'Authenticated user' do
    scenario 'tries to view his rewards' do
      sign_in(user)
      rewards = create_list(:reward, 3, user: user, question: question)
      visit reward_path

      rewards.each do |r|
        expect(page).to have_content r.question.title
        expect(page).to have_content r.title
        expect(page).to have_css 'img'
      end
    end
  end

  scenario 'Unauthenticated user tries to view rewards' do
    visit questions_path
    expect(page).not_to have_link 'Rewards'
  end
end
