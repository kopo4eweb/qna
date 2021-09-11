# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  before_action :doorkeeper_authorize!

  protect_from_forgery with: :null_session

  rescue_from CanCan::AccessDenied do
    head :forbidden
  end

  rescue_from Exception do |ex|
    render json: { errors: ex.message }, status: :internal_server_error
  end

  private

  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_ability
    @current_ability ||= Ability.new(current_resource_owner)
  end
end
