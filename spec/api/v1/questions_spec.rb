# frozen_string_literal: true

require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  describe 'GET /api/v1/questions' do
    context 'when unauthorized' do
      it 'returns 401 status if there is not access_token' do
        get '/api/v1/questions', headers: headers
        expect(response.status).to eq 401
      end

      it 'returns 401 status if access_token is invalid' do
        get '/api/v1/questions', params: { access_token: '12345' }, headers: headers
        expect(response.status).to eq 401
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'when authorized' do
      let(:access_token) { create(:access_token) }
      let!(:questions) { create_list(:question, 2) }
      let(:question) { questions.first }
      let(:question_json) { json['questions'].first }
      let!(:answers) { create_list(:answer, 3, question: question) }

      before { get '/api/v1/questions', params: { access_token: access_token.token }, headers: headers }

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(json['questions'].size).to eq questions.length
      end

      it 'returns all public fields' do
        %w[id title body created_at updated_at].each do |attr|
          expect(question_json[attr]).to eq question.send(attr).as_json
        end
      end

      it 'contains user object' do
        expect(question_json['user']['id']).to eq question.user.id
      end

      it 'contains short title' do
        expect(question_json['short_title']).to eq question.title.truncate(7)
      end

      describe 'answers' do
        let(:answer) { answers.first }
        let(:answer_json) { question_json['answers'].first }

        it 'returns list of answers' do
          expect(question_json['answers'].size).to eq answers.length
        end

        it 'returns all public fields' do
          %w[id body question_id user_id best created_at updated_at].each do |attr|
            expect(answer_json[attr]).to eq answer.send(attr).as_json
          end
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
