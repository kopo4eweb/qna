# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GistsController, type: :controller do
  describe 'GET #load' do
    let(:gist_url) { 'https://gist.github.com/kopo4eweb/ee186726f9a58f3f778888117d9f3701' }
    let(:link_id) { 1 }

    it 'returning the script body' do
      get :load, params: { url: gist_url, id: link_id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/<script>call_link_1.*/im)
    end
  end
end
