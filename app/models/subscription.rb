# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :question, touch: true
  belongs_to :user
end
