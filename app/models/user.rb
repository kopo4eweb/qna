# frozen_string_literal: true

class User < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :rewards, dependent: :nullify
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: %i[github vkontakte]

  def author_of?(item)
    id == item.user_id
  end

  def voted?(object)
    votes.exists?(votable: object)
  end

  def self.find_for_oauth(auth)
    FindForOauthService.new(auth).call
  end

  def subscribed?(question)
    subscriptions.find_by(question_id: question.id)
  end
end
