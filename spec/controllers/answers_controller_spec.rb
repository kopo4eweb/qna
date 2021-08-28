# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/controllers/concerns/voted_spec.rb')
require Rails.root.join('spec/controllers/concerns/commented_spec.rb')

# rubocop:disable Metrics/BlockLength
RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question) }

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new answer for the question in the database' do
        # rubocop:disable Style/BlockDelimiters
        expect {
          post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
        }.to change(question.answers, :count).by(1)
        # rubocop:enable Style/BlockDelimiters
      end

      it 'redirects to show view the question' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) }, format: :js
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer' do
        # rubocop:disable Style/BlockDelimiters
        expect {
          post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }, format: :js
        }.not_to change(Answer, :count)
        # rubocop:enable Style/BlockDelimiters
      end

      it 're-renders new view' do
        post :create, params: { question_id: question, answer: attributes_for(:answer, :invalid) }, format: :js
        expect(response).to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    before { login(user) }

    let!(:answer) { create(:answer, question: question, user: user) }

    context 'with valid attributes' do
      it 'change answer attributes' do
        patch :update, params: { id: answer, answer: { body: 'New answer body' } }, format: :js
        answer.reload
        expect(answer.body).to eq 'New answer body'
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: { body: 'New answer body' } }, format: :js
        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      it 'does not change answer attributes' do
        # rubocop:disable Style/BlockDelimiters
        expect {
          patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
        }.not_to change(answer, :body)
        # rubocop:enable Style/BlockDelimiters
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
        expect(response).to render_template :update
      end
    end

    context 'when user is not author' do
      let(:new_user) { create(:user) }

      before { login(new_user) }

      it 'changes answer attributes' do
        patch :update, params: {
          id: answer,
          answer: { body: 'New answer body' },
          user: new_user
        }, format: :js
        answer.reload

        expect(answer.body).not_to eq 'New answer body'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:answer) { create(:answer, question: question, user: user) }

    context 'when user is author' do
      before { login(user) }

      it 'check that answer was deleted' do
        expect { delete :destroy, params: { id: answer }, format: :js }.to change(Answer, :count).by(-1)
      end

      it 'redirects to question page' do
        delete :destroy, params: { id: answer }, format: :js
        expect(response).to render_template :destroy
      end
    end

    context 'when user is not author' do
      let(:other_user) { create(:user) }

      before { login(other_user) }

      it 'tries to delete answer' do
        expect { delete :destroy, params: { id: answer }, format: :js }.not_to change(Answer, :count)
      end

      it 'responds with forbidden' do
        delete :destroy, params: { id: answer }, format: :js
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when unauthenticated user' do
      it 'tries to delete answer' do
        expect { delete :destroy, params: { id: answer }, format: :js }.not_to change(Answer, :count)
      end

      it 'redirects to login page' do
        delete :destroy, params: { id: answer }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PATCH #select_best' do
    let!(:new_user) { create(:user) }
    let!(:question) { create(:question, user: user) }
    let!(:answer) { create(:answer, question: question, user: user) }

    context 'when authenticated user' do
      it 'author of question selected best answer' do
        login(user)
        patch :select_best, params: { id: answer }, format: :js
        answer.reload

        expect(answer.best).to be_truthy
      end

      it 'not author of question tries selected best answer' do
        login(new_user)
        patch :select_best, params: { id: answer }, format: :js
        answer.reload

        expect(answer.best).to be_falsey
      end
    end

    context 'when unauthenticated user' do
      it 'tries selected best answer' do
        patch :select_best, params: { id: answer }, format: :js
        answer.reload

        expect(answer.best).to be_falsey
      end
    end
  end

  it_behaves_like 'voted'

  it_behaves_like 'commented'
end
# rubocop:enable Metrics/BlockLength
