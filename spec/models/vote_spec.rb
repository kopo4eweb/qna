# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vote, type: :model do
  it { should belong_to(:user) }
  it { should belong_to :votable }

  it { should validate_numericality_of(:value).only_integer }
end
