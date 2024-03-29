# frozen_string_literal: true

class RewardsController < ApplicationController
  before_action :authenticate_user!

  authorize_resource

  def show
    @rewards = current_user&.rewards
  end
end
