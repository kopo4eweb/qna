# frozen_string_literal: true

require 'sphinx_helper'

RSpec.describe SearchController, type: :controller do
  let!(:query)     { 'Question' }
  let!(:resource)  { 'question' }
  let!(:pagination)  { { page: nil, per_page: 10 } }

  before { create_list(:question, 3) }

  describe 'GET#search', js: true do
    context 'when for current resource', sphinx: true do
      ThinkingSphinx::Test.run do
        before { get :search, params: { query: query, resource: resource } }

        it 'status 2xx' do
          expect(response).to be_successful
        end

        it 'renders search view' do
          expect(response).to render_template :search
        end

        it 'assigns @query' do
          expect(assigns(:query)).to eq query
        end

        it 'assigns @resource' do
          expect(assigns(:resource)).to eq resource
        end
      end
    end

    context 'when for all' do
      let!(:answer) { create(:answer) }

      it 'search engine responds for all', sphinx: true do
        ThinkingSphinx::Test.run do
          allow(ThinkingSphinx).to receive(:search).with(query, pagination)
          get :search, params: { query: query, resource: 'all' }
        end
      end

      it 'search engine responds for all and return data', sphinx: true do
        ThinkingSphinx::Test.run do
          allow(ThinkingSphinx).to receive(:search).with('Answer', pagination).and_return(answer)
          get :search, params: { query: 'Answer', resource: 'all' }
        end
      end
    end
  end
end
