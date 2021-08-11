# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :gon_user

  private

  def gon_user
    gon.current_user_id = current_user.id if signed_in?
  end
end
