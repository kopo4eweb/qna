# frozen_string_literal: true

shared_examples_for 'Checkable public fields' do
  it 'returns all public fields' do
    public_fields.each do |attr|
      expect(single_json_object[attr]).to eq single_object.send(attr).as_json
    end
  end
end
