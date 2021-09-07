# frozen_string_literal: true

shared_examples_for 'Checkable private fields' do
  it 'does not return private fields' do
    private_fields.each do |attr|
      expect(json).not_to have_key(attr)
    end
  end
end
