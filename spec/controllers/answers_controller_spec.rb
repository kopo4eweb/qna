# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question) }

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new answer for the question in the database' do
        # rubocop:disable Style/BlockDelimiters
        expect {
          post :create, params: { question_id: question, answer: attributes_for(:answer) }
        }.to change(question.answers, :count).by(1)
        # rubocop:enable Style/BlockDelimiters
      end

      it 'redirects to show view the question' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer' do
        # rubocop:disable Style/BlockDelimiters
        expect {
          post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }
        }.not_to change(Answer, :count)
        # rubocop:enable Style/BlockDelimiters
      end

      it 're-renders new view' do
        post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }
        expect(response).to render_template 'questions/show'
      end
    end
  end
end
