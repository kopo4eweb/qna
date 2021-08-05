# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'votable' do
  it { should have_many(:votes).dependent(:destroy) }

  let(:user) { create(:user) }
  let(:model) { described_class }

  describe "votes for #{described_class.to_s.downcase}" do
    it '#vote_up' do
      votable = create(model.to_s.underscore.to_sym)
      votable.vote_up(user)
      expect(votable.votes.order(created_at: :desc).first.value).to eq 1
    end

    it '#vote_down' do
      votable = create(model.to_s.underscore.to_sym)
      votable.vote_down(user)
      expect(votable.votes.order(created_at: :desc).first.value).to eq(-1)
    end

    it '#cancel_vote' do
      votable = create(model.to_s.underscore.to_sym)
      votable.vote_up(user)
      votable.cancel_vote(user)
      expect(votable.total_votes).to eq 0
    end
  end
end
