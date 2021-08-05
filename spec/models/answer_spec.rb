# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/models/concerns/votable_spec.rb')

RSpec.describe Answer, type: :model do
  it { should belong_to(:question) }
  it { should belong_to(:user) }

  it { should have_many(:links).dependent(:destroy) }

  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :links }

  describe 'switch_best' do
    let!(:user) { create(:user) }
    let!(:question) { create(:question, user: user) }
    let!(:reward) { create(:reward, question: question) }
    let!(:answer) { create(:answer, question: question, user: user) }
    let!(:best_answer) { create(:answer, question: question, user: user, best: true) }

    it 'check best attribute for new best answer' do
      answer.switch_best

      expect(answer).to be_best
      expect(reward.user).not_to be_nil
    end

    it 'check best attribute for old best answer' do
      answer.switch_best
      best_answer.reload

      expect(best_answer).not_to be_best
    end
  end

  it 'have many attached files' do
    expect(described_class.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end

  it_behaves_like 'votable'
end
