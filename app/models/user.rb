# frozen_string_literal: true

class User < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :rewards, dependent: :nullify
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :authorizations, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[github]

  def author_of?(item)
    id == item.user_id
  end

  def voted?(object)
    votes.exists?(votable: object)
  end

  def self.find_for_oauth(auth)
    authorization = Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
    return authorization.user if authorization

    email = auth.info[:email]
    user = User.find_by(email: email)

    unless user
      password = Devise.friendly_token[0, 20]
      user = User.create!(email: email, password: password, password_confirmation: password)
    end

    user.authorizations.create(provider: auth.provider, uid: auth.uid.to_s)

    user
  end
end
