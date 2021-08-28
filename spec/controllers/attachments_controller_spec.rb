# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe AttachmentsController, type: :controller do
  let(:user) { create(:user) }
  let!(:question) { create(:question, :with_attachment, user: user) }
  let(:question_file) { question.files[0] }
  let!(:answer) { create(:answer, :with_attachment, question: question, user: user) }
  let(:answer_file) { answer.files[0] }
  let(:other_user) { create(:user) }

  describe 'DELETE #destroy' do
    context 'when user is author' do
      before { login(user) }

      context 'when question' do
        it 'deletes the file from own question' do
          expect do
            delete :destroy, params: { id: question_file.id }, format: :js
          end.to change(question.files, :count).by(-1)
        end

        it 'render template destroy' do
          delete :destroy, params: { id: question_file.id }, format: :js
          expect(response).to render_template :destroy
        end
      end

      context 'when answer' do
        it 'deletes the file from own answer' do
          expect do
            delete :destroy, params: { id: answer_file.id }, format: :js
          end.to change(answer.files, :count).by(-1)
        end

        it 'render template destroy' do
          delete :destroy, params: { id: answer_file.id }, format: :js
          expect(response).to render_template :destroy
        end
      end
    end

    context 'when user is not author' do
      before { login(other_user) }

      context 'when question' do
        it 'tries to delete file from question' do
          expect do
            delete :destroy, params: { id: question_file.id }, format: :js
          end.not_to change(question.files, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: question_file.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when answer' do
        it 'tries to delete file from answer' do
          expect do
            delete :destroy, params: { id: answer_file.id }, format: :js
          end.not_to change(answer.files, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: answer_file.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when unauthenticated user' do
      context 'when question' do
        it 'tries to delete file from question' do
          expect do
            delete :destroy, params: { id: question_file.id }, format: :js
          end.not_to change(question.files, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: question_file.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when answer' do
        it 'tries to delete file from answer' do
          expect do
            delete :destroy, params: { id: answer_file.id }, format: :js
          end.not_to change(answer.files, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: answer_file.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
