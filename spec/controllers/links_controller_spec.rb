# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe LinksController, type: :controller do
  let(:user) { create(:user) }
  let!(:question) { create(:question, :with_links, user: user) }
  let(:question_link) { question.links.first }
  let!(:answer) { create(:answer, :with_links, question: question, user: user) }
  let(:answer_link) { answer.links.first }
  let(:other_user) { create(:user) }

  describe 'DELETE #destroy' do
    context 'when user is author' do
      before { login(user) }

      context 'when question' do
        it 'deletes the link from own question' do
          expect do
            delete :destroy, params: { id: question_link.id }, format: :js
          end.to change(question.links, :count).by(-1)
        end

        it 'render template destroy' do
          delete :destroy, params: { id: question_link.id }, format: :js
          expect(response).to render_template :destroy
        end
      end

      context 'when answer' do
        it 'deletes the link from own answer' do
          expect do
            delete :destroy, params: { id: answer_link.id }, format: :js
          end.to change(answer.links, :count).by(-1)
        end

        it 'render template destroy' do
          delete :destroy, params: { id: answer_link.id }, format: :js
          expect(response).to render_template :destroy
        end
      end
    end

    context 'when user is not author' do
      before { login(other_user) }

      context 'when question' do
        it 'tries to delete link from question' do
          expect do
            delete :destroy, params: { id: question_link.id }, format: :js
          end.not_to change(question.links, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: question_link.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when answer' do
        it 'tries to delete link from answer' do
          expect do
            delete :destroy, params: { id: answer_link.id }, format: :js
          end.not_to change(answer.links, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: answer_link.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when unauthenticated user' do
      context 'when question' do
        it 'tries to delete link from question' do
          expect do
            delete :destroy, params: { id: question_link.id }, format: :js
          end.not_to change(question.links, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: question_link.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'when answer' do
        it 'tries to delete link from answer' do
          expect do
            delete :destroy, params: { id: answer_link.id }, format: :js
          end.not_to change(answer.links, :count)
        end

        it 'responds with forbidden' do
          delete :destroy, params: { id: answer_link.id }, format: :js
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
