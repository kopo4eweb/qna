# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      user.admin? ? admin_abilities : user_abilities(user)
    else
      guest_abilities
    end
  end

  private

  def guest_abilities
    can :read, :all
    can :email, User
    can :set_email, User
  end

  def admin_abilities
    can :manage, :all
  end

  def user_abilities(user)
    guest_abilities

    can :create, [Question, Answer]
    can :update, [Question, Answer], user_id: user.id
    can :destroy, [Question, Answer], user_id: user.id

    can :select_best, Answer do |answer|
      user.author_of?(answer.question)
    end

    can :destroy, Link, linkable: { user_id: user.id }

    can :add_comment, [Question, Answer]

    alias_action :vote_up, :vote_down, :cancel_vote, to: :vote
    can :vote, [Question, Answer] do |resource|
      !user.author_of?(resource)
    end

    can :read, Reward

    can :destroy, ActiveStorage::Attachment, record: { user_id: user.id }
  end
end
