# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachmentsController, type: :controller do
  let(:user) { create(:user) }
  let!(:question) { create(:question, :with_attachment, user: user) }
  let(:question_file) { question.files[0] }

  describe 'DELETE #destroy' do
    context 'when user is author' do
      before { login(user) }

      context 'when question' do
        it 'deletes the file from question' do
          expect do
            delete :destroy, params: { id: question_file.id }, format: :js
          end.to change(question.files, :count).by(-1)
        end

        it 'render template destroy' do
          delete :destroy, params: { id: question_file.id }, format: :js
          expect(response).to render_template :destroy
        end
      end
    end

    context 'when user is not author' do
      let(:other_user) { create(:user) }

      before { login(other_user) }

      context 'when question' do
        it 'tries to delete file from question' do
          expect do
            delete :destroy, params: { id: question_file.id }, format: :js
          end.not_to change(question.files, :count)
        end

        it 'render template destroy' do
          delete :destroy, params: { id: question_file.id }, format: :js
          expect(response).to render_template :destroy
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

        it 'render template destroy' do
          delete :destroy, params: { id: question_file.id }, format: :js
          expect(response).to render_template :destroy
        end
      end
    end
  end
end
