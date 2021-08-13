# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'commented' do
  resource_factory = described_class.controller_name.classify.underscore.to_sym

  let!(:user) { create(:user) }
  let!(:resource) { create(resource_factory, user_id: user.id) }

  describe 'POST#add_comment' do
    before { login(user) }

    it 'create a new comment' do
      expect do
        post :add_comment, params: { id: resource, comment: { body: 'Test Comment' }, format: :js }
      end.to change(Comment, :count).by(1)
    end

    it 'responds with js' do
      post :add_comment, params: { id: resource, comment: { body: 'Test Comment' } }, format: :js
      expect(response.content_type).to eq 'text/javascript; charset=utf-8'
    end
  end
end
