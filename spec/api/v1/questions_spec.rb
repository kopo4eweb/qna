# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'Questions API', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
  let(:user) { create(:user) }
  let(:access_token) { create(:access_token, resource_owner_id: user.id) }

  describe 'GET /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'when authorized' do
      let!(:questions) { create_list(:question, 2) }
      let(:question) { questions.first }
      let(:question_json) { json['questions'].first }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(json['questions'].size).to eq questions.length
      end

      it_behaves_like 'Checkable public fields' do
        let(:public_fields) { %w[id title body created_at updated_at] }
        let(:single_json_object) { question_json }
        let(:single_object) { question }
      end

      it 'contains short title' do
        expect(question_json['short_title']).to eq question.title.truncate(7)
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end

  describe 'GET /api/v1/questions/:id' do
    let!(:question) { create(:question, :with_answers, :with_attachment, :with_links, :with_comments) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'when authorized' do
      let(:question_json) { json['question'] }
      let(:content_types) { %w[answers comments files links] }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'contains user object' do
        expect(question_json['user']['id']).to eq question.user.id
      end

      it_behaves_like 'Checkable public fields' do
        let(:public_fields) { %w[id title body created_at updated_at] }
        let(:single_json_object) { question_json }
        let(:single_object) { question }
      end

      it 'contains list of all content_type' do
        content_types.each do |type|
          expect(question_json[type].size).to eq question.send(type).count
          expect(question_json[type].first['id']).to eq question.send(type).first.id
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end

  describe 'POST /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :post }
    end

    context 'when authorized' do
      context 'with valid attributes' do
        before do
          post api_path,
               params: { question: { title: 'Test question', body: 'text text text' },
                         access_token: access_token.token },
               headers: headers
        end

        it 'create new Question' do
          expect do
            post api_path, params: { question: attributes_for(:question), access_token: access_token.token },
                           headers: headers
          end.to change(Question, :count).by(1)
        end

        it 'returns 200 status' do
          expect(response).to be_successful
        end

        it 'returns new question' do
          expect(json['question']['title']).to eq 'Test question'
          expect(json['question']['body']).to eq 'text text text'
        end

        it 'contains user object' do
          expect(json['question']['user']['id']).to eq access_token.resource_owner_id
        end
      end

      context 'with invalid attributes' do
        before do
          post api_path, params: { question: attributes_for(:question, :invalid), access_token: access_token.token },
                         headers: headers
        end

        it 'does not create new Question' do
          expect do
            post api_path, params: { question: attributes_for(:question, :invalid), access_token: access_token.token },
                           headers: headers
          end.not_to change(Question, :count)
        end

        it 'returns 422 status' do
          expect(response.status).to eq 422
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
        end
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let!(:question) { create(:question, user: user) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :patch }
    end

    context 'when authorized' do
      context 'with valid attributes' do
        before do
          patch api_path,
                params: { question: { title: 'Edit title', body: 'Edit body text' },
                          access_token: access_token.token },
                headers: headers
        end

        it 'returns 200 status' do
          expect(response).to be_successful
        end

        it 'returns update question' do
          expect(json['question']['title']).to eq 'Edit title'
          expect(json['question']['body']).to eq 'Edit body text'
        end

        it 'contains user object' do
          expect(json['question']['user']['id']).to eq access_token.resource_owner_id
        end
      end

      # rubocop:disable RSpec/MultipleMemoizedHelpers
      context 'with invalid attributes' do
        let(:old_title) { question.title }
        let(:old_body) { question.body }

        before do
          patch api_path, params: { question: attributes_for(:question, :invalid), access_token: access_token.token },
                          headers: headers
        end

        it 'does not update Question' do
          expect(question.title).to eq old_title
          expect(question.body).to eq old_body
        end

        it 'returns 422 status' do
          expect(response.status).to eq 422
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
        end
      end

      context 'when authorized not author' do
        let!(:other_user)      { create(:user) }
        let!(:other_question)  { create(:question, user: other_user) }
        let!(:other_api_path)  { "/api/v1/questions/#{other_question.id}" }
        let!(:other_old_title) { other_question.title }
        let!(:other_old_body)  { other_question.body }

        it 'does not update Question' do
          do_request(:patch, other_api_path,
                     params: { question: { title: 'Edit title', body: 'Edit body' },
                               access_token: access_token.token },
                     headers: headers)

          expect(other_question.title).to eq other_old_title
          expect(other_question.body).to eq other_old_body
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let!(:question) { create(:question, user: user) }
    let!(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :delete }
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'when authorized' do
      it 'deletes the question' do
        expect do
          delete api_path, params: { access_token: access_token.token }, headers: headers
        end.to change(Question, :count).by(-1)
      end

      it 'returns 200 status' do
        delete api_path, params: { access_token: access_token.token }, headers: headers
        expect(response).to be_successful
      end

      it 'returns deleted question json' do
        delete api_path, params: { access_token: access_token.token }, headers: headers
        %w[id title body created_at updated_at].each do |attr|
          expect(json['question'][attr]).to eq question.send(attr).as_json
        end
      end

      context 'when authorized not author' do
        let!(:other_user)     { create(:user) }
        let!(:other_question) { create(:question, user: other_user) }
        let(:other_api_path)  { "/api/v1/questions/#{other_question.id}" }

        it 'does non deletes the question' do
          expect do
            delete other_api_path, params: { access_token: access_token.token }, headers: headers
          end.not_to change(Question, :count)
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
# rubocop:enable Metrics/BlockLength
