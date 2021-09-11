# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable RSpec/MultipleMemoizedHelpers
describe 'Questions API', type: :request do
  let!(:headers) { { 'ACCEPT' => 'application/json' } }
  let!(:user) { create(:user) }
  let!(:access_token) { create(:access_token, resource_owner_id: user.id) }
  let(:user_id) { access_token.resource_owner_id }

  describe 'GET /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    context 'when authorized' do
      let!(:questions) { create_list(:question, 2) }
      let(:question) { questions.first }
      let(:question_json) { json['questions'].first }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it_behaves_like 'Checkable status 200'

      it_behaves_like 'Checkable size collection' do
        let(:list_obj_json) { json['questions'] }
        let(:list_obj) { questions }
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
  end

  describe 'GET /api/v1/questions/:id' do
    let!(:question) { create(:question, :with_answers, :with_attachment, :with_links, :with_comments) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    context 'when authorized' do
      let(:question_json) { json['question'] }
      let(:content_types) { %w[answers comments files links] }
      let(:single_json_object) { question_json }
      let(:single_object) { question }
      let(:user_id) { question.user.id }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it_behaves_like 'Checkable status 200'

      it_behaves_like 'Checkable contains user object'

      it_behaves_like 'Checkable public fields' do
        let(:public_fields) { %w[id title body created_at updated_at] }
      end

      it_behaves_like 'Checkable content_type of collection'
    end
  end

  describe 'POST /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :post }
    end

    context 'when authorized' do
      context 'with valid attributes' do
        let(:single_json_object) { json['question'] }

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

        it_behaves_like 'Checkable status 200'

        it 'returns new question' do
          expect(single_json_object['title']).to eq 'Test question'
          expect(single_json_object['body']).to eq 'text text text'
        end

        it_behaves_like 'Checkable contains user object'
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

        it_behaves_like 'Checkable status 422'

        it_behaves_like 'Checkable returns error'
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
      let(:single_json_object) { json['question'] }

      context 'with valid attributes' do
        before do
          patch api_path,
                params: { question: { title: 'Edit title', body: 'Edit body text' },
                          access_token: access_token.token },
                headers: headers
        end

        it_behaves_like 'Checkable status 200'

        it 'returns update question' do
          expect(single_json_object['title']).to eq 'Edit title'
          expect(single_json_object['body']).to eq 'Edit body text'
        end

        it_behaves_like 'Checkable contains user object'
      end

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

        it_behaves_like 'Checkable status 422'

        it_behaves_like 'Checkable returns error'
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
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let!(:question) { create(:question, user: user) }
    let!(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :delete }
    end

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
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
# rubocop:enable Metrics/BlockLength
