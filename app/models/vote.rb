# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true, touch: true
  belongs_to :user

  validates :value, numericality: { only_integer: true }
end
