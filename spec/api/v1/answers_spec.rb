# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable RSpec/MultipleMemoizedHelpers
describe 'Answers API', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
  let(:user) { create(:user) }
  let(:access_token) { create(:access_token, resource_owner_id: user.id) }
  let(:user_id) { access_token.resource_owner_id }

  describe 'GET /api/v1/questions/:question_id/answers' do
    let!(:question) { create(:question) }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    context 'when authorized' do
      let!(:answers) { create_list(:answer, 3, question: question) }
      let(:answer) { answers.first }
      let(:answer_json) { json['answers'].first }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it_behaves_like 'Checkable status 200'

      it_behaves_like 'Checkable size collection' do
        let(:list_obj_json) { json['answers'] }
        let(:list_obj) { answers }
      end

      it_behaves_like 'Checkable public fields' do
        let(:public_fields) { %w[id body created_at updated_at] }
        let(:single_json_object) { answer_json }
        let(:single_object) { answer }
      end
    end
  end

  describe 'GET /api/v1/answers/:id' do
    let!(:answer) { create(:answer, :with_attachment, :with_links, :with_comments) }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    context 'when authorized' do
      let(:answer_json) { json['answer'] }
      let(:content_types) { %w[comments files links] }
      let(:single_json_object) { answer_json }
      let(:single_object) { answer }
      let(:user_id) { answer.user.id }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it_behaves_like 'Checkable status 200'

      it_behaves_like 'Checkable contains user object'

      it_behaves_like 'Checkable public fields' do
        let(:public_fields) { %w[id body created_at updated_at] }
      end

      it_behaves_like 'Checkable content_type of collection'
    end
  end

  describe 'POST /api/v1/questions/question_id/answers' do
    let!(:question) { create(:question) }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :post }
    end

    context 'when authorized' do
      context 'with valid attributes' do
        let(:single_json_object) { json['answer'] }

        before do
          post api_path,
               params: { answer: { body: 'text text text' },
                         access_token: access_token.token },
               headers: headers
        end

        it 'create new Answer' do
          expect do
            post api_path, params: { answer: attributes_for(:answer), access_token: access_token.token },
                           headers: headers
          end.to change(Answer, :count).by(1)
        end

        it_behaves_like 'Checkable status 200'

        it 'returns new answer' do
          expect(single_json_object['body']).to eq 'text text text'
        end

        it_behaves_like 'Checkable contains user object'
      end

      context 'with invalid attributes' do
        before do
          post api_path, params: { answer: attributes_for(:answer, :invalid), access_token: access_token.token },
                         headers: headers
        end

        it 'does not create new Question' do
          expect do
            post api_path, params: { answer: attributes_for(:answer, :invalid), access_token: access_token.token },
                           headers: headers
          end.not_to change(Answer, :count)
        end

        it_behaves_like 'Checkable status 422'

        it_behaves_like 'Checkable returns error'
      end
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let!(:answer) { create(:answer, user: user) }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :patch }
    end

    context 'when authorized' do
      let(:single_json_object) { json['answer'] }

      context 'with valid attributes' do
        before do
          patch api_path,
                params: { answer: { body: 'Edit body text' },
                          access_token: access_token.token },
                headers: headers
        end

        it_behaves_like 'Checkable status 200'

        it 'returns update answer' do
          expect(single_json_object['body']).to eq 'Edit body text'
        end

        it_behaves_like 'Checkable contains user object'
      end

      context 'with invalid attributes' do
        let(:old_body) { answer.body }

        before do
          patch api_path, params: { answer: attributes_for(:answer, :invalid), access_token: access_token.token },
                          headers: headers
        end

        it 'does not update Answer' do
          expect(answer.body).to eq old_body
        end

        it_behaves_like 'Checkable status 422'

        it_behaves_like 'Checkable returns error'
      end

      context 'when authorized not author' do
        let!(:other_user) { create(:user) }
        let!(:other_answer) { create(:answer, user: other_user) }
        let!(:other_api_path) { "/api/v1/answers/#{other_answer.id}" }
        let!(:other_old_body) { other_answer.body }

        it 'does not update Answer' do
          do_request(:patch, other_api_path,
                     params: { question: { body: 'Edit body' },
                               access_token: access_token.token },
                     headers: headers)

          expect(other_answer.body).to eq other_old_body
        end
      end
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let!(:answer) { create(:answer, user: user) }
    let!(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :delete }
    end

    context 'when authorized' do
      it 'deletes the answer' do
        expect do
          delete api_path, params: { access_token: access_token.token }, headers: headers
        end.to change(Answer, :count).by(-1)
      end

      it 'returns 200 status' do
        delete api_path, params: { access_token: access_token.token }, headers: headers
        expect(response).to be_successful
      end

      it 'returns deleted question json' do
        delete api_path, params: { access_token: access_token.token }, headers: headers
        %w[id body created_at updated_at].each do |attr|
          expect(json['answer'][attr]).to eq answer.send(attr).as_json
        end
      end

      context 'when authorized not author' do
        let!(:other_user) { create(:user) }
        let!(:other_answer) { create(:answer, user: other_user) }
        let(:other_api_path) { "/api/v1/answers/#{other_answer.id}" }

        it 'does non deletes the answer' do
          expect do
            delete other_api_path, params: { access_token: access_token.token }, headers: headers
          end.not_to change(Answer, :count)
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
# rubocop:enable Metrics/BlockLength
