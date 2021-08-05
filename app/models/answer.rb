# frozen_string_literal: true

class Answer < ApplicationRecord
  include Votable

  belongs_to :user
  belongs_to :question

  has_many :links, dependent: :destroy, as: :linkable

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

  validates :body, presence: true

  def switch_best
    transaction do
      # rubocop:disable Rails/SkipsModelValidations
      question.answers.update_all(best: false)
      # rubocop:enable Rails/SkipsModelValidations
      update!(best: true)
      question.reward&.update!(user: user)
    end
  end
end
