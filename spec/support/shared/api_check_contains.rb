# frozen_string_literal: true

shared_examples_for 'Checkable size collection' do
  it 'returns list of object' do
    expect(list_obj_json.size).to eq list_obj.length
  end
end

shared_examples_for 'Checkable content_type of collection' do
  it 'contains list of all content_type' do
    content_types.each do |type|
      expect(single_json_object[type].size).to eq single_object.send(type).count
      expect(single_json_object[type].first['id']).to eq single_object.send(type).first.id
    end
  end
end

shared_examples_for 'Checkable contains user object' do
  it 'contains user object' do
    expect(single_json_object['user']['id']).to eq user_id
  end
end
