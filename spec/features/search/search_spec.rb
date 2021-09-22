# frozen_string_literal: true

require 'sphinx_helper'

feature 'User can search for answers throughout site ', %q(
  any user should be able to search by keyword\phrase throughout the site
) do
  given!(:questions) { create_list(:question, 3, title: 'title question') }
  given!(:answers) { create_list(:answer, 2, body: 'title answer', question: questions[0]) }
  given!(:comments) { create_list(:comment, 2, body: 'titlecomments', commentable: questions[0]) }
  given!(:user) { create(:user, email: 'title@test.ru') }

  shared_examples_for 'Search with params' do |query|
    scenario 'fill form and send request', js: true do
      ThinkingSphinx::Test.run do
        visit root_path

        fill_in 'query', with: query
        click_on 'Go'

        expect(page).to have_content(query)
      end
    end
  end

  context 'when by all categories', sphinx: true do
    it_behaves_like 'Search with params', 'title'
  end

  context 'when search only among questions', sphinx: true do
    it_behaves_like 'Search with params', 'question'
  end

  context 'when search only among answers', sphinx: true do
    it_behaves_like 'Search with params', 'answer'
  end

  context 'when search only among comments', sphinx: true do
    it_behaves_like 'Search with params', 'titlecomments'
  end

  context 'when search only among users', sphinx: true do
    it_behaves_like 'Search with params', 'test'
  end
end
