# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe 'Check author' do
    let(:user) { create(:user) }

    describe 'a question' do
      it 'current user is an author' do
        question = create(:question, user: user)
        expect(user).to be_author_of(question)
      end

      it "current user isn't an author" do
        question = create(:question)
        expect(user).not_to be_author_of(question)
      end
    end

    describe 'an answer' do
      it 'current user is an author' do
        answer = create(:answer, user: user)
        expect(user).to be_author_of(answer)
      end

      it "current user isn't an author" do
        answer = create(:answer)
        expect(user).not_to be_author_of(answer)
      end
    end
  end
end
