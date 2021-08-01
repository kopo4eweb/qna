# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:rewards) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe 'Check author' do
    let(:user) { create(:user) }
    let(:author_question) { create(:question, user: user) }
    let(:question) { create(:question) }

    describe 'a question' do
      it 'current user is an author' do
        expect(user).to be_author_of(author_question)
      end

      it "current user isn't an author" do
        expect(user).not_to be_author_of(question)
      end
    end
  end
end
