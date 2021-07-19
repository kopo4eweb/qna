# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :body, presence: true

  def switch_best
    transaction do
      # rubocop:disable Rails/SkipsModelValidations
      question.answers.update_all(best: false)
      # rubocop:enable Rails/SkipsModelValidations
      update!(best: true)
    end
  end
end
