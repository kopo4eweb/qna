# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'voted' do
  resource_factory = described_class.controller_name.classify.underscore.to_sym

  let!(:user) { create(:user) }
  let!(:new_user) { create(:user) }
  let!(:resource) { create(resource_factory, user_id: user.id) }

  before { create_list(resource_factory, 3, user_id: new_user.id) }

  describe 'POST#vote_up' do
    context 'when authenticated user' do
      context 'when not author' do
        before { login(new_user) }

        it 'assigns a voting resource' do
          post :vote_up, params: { id: resource.id }, format: :json
          expect(assigns(:votable)).to eq resource
        end

        it 'creates a new vote' do
          expect do
            post :vote_up, params: { id: resource.id }, format: :json
            resource.reload
          end.to change(resource.votes, :count).by(1)
        end

        it 'responds with json' do
          post :vote_up, params: { id: resource.id }, format: :json
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end
      end
    end
  end

  describe 'POST#vote_down' do
    context 'when authenticated user' do
      context 'when not author' do
        before { login(new_user) }

        it 'assigns a voting resource' do
          post :vote_down, params: { id: resource.id }, format: :json
          expect(assigns(:votable)).to eq resource
        end

        it 'creates a new vote' do
          expect do
            post :vote_down, params: { id: resource.id }, format: :json
            resource.reload
          end.to change(resource.votes, :count).by(1)
        end

        it 'responds with json' do
          post :vote_down, params: { id: resource.id }, format: :json
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end
      end
    end
  end

  describe 'POST#cancel_vote' do
    context 'when authenticated user' do
      context 'when not author' do
        before { login(new_user) }

        it 'assigns a voting resource' do
          delete :cancel_vote, params: { id: resource.id }, format: :json
          expect(assigns(:votable)).to eq resource
        end

        it 'deletes a vote' do
          expect do
            patch :vote_up, params: { id: resource.id }, format: :json
            delete :cancel_vote, params: { id: resource.id }, format: :json
            resource.reload
          end.to change(resource.votes, :count).by(0)
        end

        it 'responds with json' do
          delete :cancel_vote, params: { id: resource.id }, format: :json
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end
      end
    end
  end
end
