# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/controllers/concerns/voted_spec.rb')
require Rails.root.join('spec/controllers/concerns/commented_spec.rb')

# rubocop:disable Metrics/BlockLength
RSpec.describe QuestionsController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question) }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 3) }

    before { get :index }

    it 'populates an array of all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'assigns new answer for question' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'assigns new link for answer' do
      expect(assigns(:answer).links.first).to be_a_new(Link)
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before do
      login(user)
      get :new
    end

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'assigns a new Link to @question' do
      expect(assigns(:question).links.first).to be_a_new(Link)
    end

    it 'assigns a new Reward to @question' do
      expect(assigns(:question).reward).to be_a_new(Reward)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      let(:question) { create(:question, user: user) }

      it 'saves a new question is the database' do
        expect { post :create, params: { question: attributes_for(:question) } }.to change(Question, :count).by(1)
      end

      it 'created by current user' do
        post :create, params: { question: attributes_for(:question) }
        expect(assigns(:question).user_id).to eq question.user_id
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the question' do
        # rubocop:disable Style/BlockDelimiters
        expect {
          post :create, params: { question: attributes_for(:question, :invalid) }
        }.not_to change(Question, :count)
        # rubocop:enable Style/BlockDelimiters
      end

      it 're-renders new view' do
        post :create, params: { question: attributes_for(:question, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    before { login(user) }

    let!(:question) { create(:question, user: user) }

    context 'with valid attributes' do
      before do
        patch :update,
              params: {
                id: question,
                question: { title: 'New question', body: 'New question body' }
              },
              format: :js
      end

      it 'change question attributes' do
        question.reload
        expect(question.title).to eq 'New question'
        expect(question.body).to eq 'New question body'
      end

      it 'renders update view' do
        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      it 'does not change question attributes' do
        # rubocop:disable Style/BlockDelimiters
        expect {
          patch :update, params: { id: question, question: attributes_for(:question, :invalid) }, format: :js
        }.not_to change(question, :title)
        # rubocop:enable Style/BlockDelimiters
      end

      it 'renders update view' do
        patch :update, params: { id: question, question: attributes_for(:question, :invalid) }, format: :js
        expect(response).to render_template :update
      end
    end

    context 'when user is not author' do
      let(:new_user) { create(:user) }

      before { login(new_user) }

      it 'changes question attributes' do
        patch :update, params: {
          id: question,
          question: { title: 'New question', body: 'New question body' },
          user: new_user
        }, format: :js
        question.reload

        expect(question.title).not_to eq 'New question'
        expect(question.body).not_to eq 'New question body'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:question) { create(:question, user: user) }

    context 'when user is author' do
      before { login(user) }

      it 'checks that question was deleted' do
        expect { delete :destroy, params: { id: question } }.to change(Question, :count).by(-1)
      end

      it 'redirects to questions list' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to questions_path
      end
    end

    context 'when user is not author' do
      let(:new_user) { create(:user) }

      before { login(new_user) }

      it 'tries to delete a question' do
        expect { delete :destroy, params: { id: question } }.not_to change(Question, :count)
      end

      it 'redirects to root path' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to root_path
      end
    end

    context 'when unauthenticated user' do
      it 'tries to delete a question' do
        expect { delete :destroy, params: { id: question } }.not_to change(Question, :count)
      end

      it 'redirects to login page' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET #subscribe' do
    let!(:user) { create(:user) }
    let!(:question) { create(:question) }

    before { login(user) }

    it 'assigns the requested question to @question' do
      get :subscribe, params: { id: question.id }, xhr: true
      expect(assigns(:question)).to eq question
    end

    it 'creates new Subscription for user' do
      expect do
        get :subscribe, params: { id: question.id }, xhr: true
      end.to change(Subscription, :count).by(1)
    end

    it 'notifies user' do
      get :subscribe, params: { id: question.id }, xhr: true
      expect(response).to render_template :subscribe
    end

    context 'when user already subscribed' do
      it 'unsubscribes' do
        question.subscriptions.create(user: user)
        expect do
          get :subscribe, params: { id: question.id }, xhr: true
        end.to change(Subscription, :count).by(-1)
      end

      it 'notifies user' do
        get :subscribe, params: { id: question.id }, xhr: true
        expect(response).to render_template :subscribe
      end
    end
  end

  it_behaves_like 'voted'

  it_behaves_like 'commented'
end
# rubocop:enable Metrics/BlockLength
