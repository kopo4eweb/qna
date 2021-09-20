# frozen_string_literal: true

class Question < ApplicationRecord
  include Votable
  include Commentable

  belongs_to :user

  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_one :reward, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :reward, reject_if: :all_blank, allow_destroy: true

  scope :created_in_a_day, -> { where('created_at >= ?', 1.day.ago) }

  after_create :subscribe_author

  validates :title, :body, presence: true

  private

  def subscribe_author
    subscriptions.create!(user: user)
  end
end
