# frozen_string_literal: true

shared_examples_for 'API Authorizable' do
  context 'when unauthorized' do
    it 'returns 401 status if there is not access_token' do
      do_request(method_name, api_path, headers: headers)
      expect(response.status).to eq 401
    end

    it 'returns 401 status if access_token is invalid' do
      do_request(method_name, api_path, params: { access_token: '12345' }, headers: headers)
      expect(response.status).to eq 401
    end
  end
end
