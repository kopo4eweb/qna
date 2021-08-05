# frozen_string_literal: true

module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def vote_up(user)
    make_vote(user, 1) unless user.voted?(self)
  end

  def vote_down(user)
    make_vote(user, -1) unless user.voted?(self)
  end

  def cancel_vote(user)
    votes.find_by(user: user).destroy if user.voted?(self)
  end

  def total_votes
    votes.sum(:value)
  end

  private

  def make_vote(user, value)
    votes.create({ user: user, value: value })
  end
end
