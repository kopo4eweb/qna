# frozen_string_literal: true

shared_examples_for 'Checkable status 200' do
  it 'returns 200 status' do
    expect(response).to be_successful
  end
end

shared_examples_for 'Checkable status 422' do
  it 'returns 422 status' do
    expect(response.status).to eq 422
  end
end

shared_examples_for 'Checkable returns error' do
  it 'returns errors' do
    expect(json['errors']).not_to be_nil
  end
end
