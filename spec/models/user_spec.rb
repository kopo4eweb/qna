# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:rewards) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }

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

  describe 'Check voted' do
    let!(:user) { create(:user) }
    let!(:new_user) { create(:user) }

    let!(:question) { create(:question, user: new_user) }
    let!(:new_question) { create(:question, user: user) }

    it 'user has been vote' do
      create(:vote, user: user, votable: question)
      expect(user).to be_voted(question)
    end

    it 'user has not been vote' do
      expect(user).not_to be_voted(new_question)
    end
  end
end
