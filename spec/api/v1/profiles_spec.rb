# frozen_string_literal: true

require 'rails_helper'

describe 'Profiles API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
  let!(:me) { create(:user, admin: true) }

  describe 'GET /api/v1/profiles/me' do
    let(:api_path) { '/api/v1/profiles/me' }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    context 'when authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }
      let(:user_json) { json['user'] }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it_behaves_like 'Checkable status 200'

      it_behaves_like 'Checkable public fields' do
        let(:public_fields) { %w[id email admin created_at updated_at] }
        let(:single_json_object) { user_json }
        let(:single_object) { me }
      end

      it_behaves_like 'Checkable private fields' do
        let(:private_fields) { %w[password encrypted_password] }
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'GET /api/v1/profiles/users_without_me' do
    let(:api_path) { '/api/v1/profiles/users_without_me' }

    it_behaves_like 'API Authorizable' do
      let(:method_name) { :get }
    end

    context 'when authorized' do
      let!(:users) { create_list(:user, 3) }
      let(:user) { users.first }
      let(:user_json) { json['users'].first }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it_behaves_like 'Checkable status 200'

      it_behaves_like 'Checkable size collection' do
        let(:list_obj_json) { json['users'] }
        let(:list_obj) { users }
      end

      it 'not contains user authorize object' do
        json['users'].each do |user|
          expect(user['id']).not_to eq me.id
        end
      end

      it_behaves_like 'Checkable public fields' do
        let(:public_fields) { %w[id email admin created_at updated_at] }
        let(:single_json_object) { user_json }
        let(:single_object) { user }
      end

      it_behaves_like 'Checkable private fields' do
        let(:private_fields) { %w[password encrypted_password] }
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
