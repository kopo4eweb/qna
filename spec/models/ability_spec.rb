# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ability' do
  subject(:ability) { Ability.new(user) }

  describe 'when guest' do
    let(:user) { nil }

    it { should be_able_to :read, Question }
    it { should be_able_to :read, Answer }
    it { should be_able_to :read, Comment }

    it { should be_able_to :email, User }
    it { should be_able_to :set_email, User }

    it { should_not be_able_to :manage, :all }
  end

  describe 'when admin' do
    let(:user) { create(:user, admin: true) }

    it { should be_able_to :manage, :all }
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'when user' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    let(:question) { create(:question, user: user) }
    let(:other_question) { create(:question, user: other_user) }
    let(:question_with_attach) { create :question, :with_attachment, user: user }

    let(:answer) { create(:answer, question: question, user: user) }
    let(:other_answer) { create(:answer, question: question, user: other_user) }

    it { should_not be_able_to :manage, :all }
    it { should be_able_to :read, :all }

    it { should be_able_to :index, Reward }

    it { should be_able_to :subscribe, Question }

    describe 'Question' do
      it { should be_able_to :create, Question }
      it { should be_able_to :update, question }
      it { should be_able_to :destroy, question }

      it { should_not be_able_to :update, other_question }
      it { should_not be_able_to :destroy, other_question }
    end

    describe 'Answer' do
      it { should be_able_to :create, Answer }
      it { should be_able_to :update, answer }
      it { should be_able_to :destroy, answer }

      it { should_not be_able_to :update, other_answer }
      it { should_not be_able_to :destroy, other_answer }

      it { should be_able_to :select_best, answer }
    end

    describe 'Link' do
      it { should be_able_to :destroy, create(:link, linkable: question) }
      it { should_not be_able_to :destroy, create(:link, linkable: other_question) }

      it { should be_able_to :destroy, create(:link, linkable: answer) }
      it { should_not be_able_to :destroy, create(:link, linkable: other_answer) }
    end

    describe 'Comments' do
      it { should be_able_to :add_comment, question }
      it { should be_able_to :add_comment, answer }
    end

    describe 'Votes' do
      it { should_not be_able_to %i[vote_up vote_down cancel_vote], question }
      it { should be_able_to %i[vote_up vote_down cancel_vote], other_question }

      it { should_not be_able_to %i[vote_up vote_down cancel_vote], answer }
      it { should be_able_to %i[vote_up vote_down cancel_vote], other_answer }
    end

    context 'when remove attachment' do
      it { should be_able_to :destroy, question_with_attach.files.first, record: question_with_attach }
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
