# frozen_string_literal: true

class Api::V1::ProfilesController < Api::V1::BaseController
  def me
    authorize! :read, current_resource_owner
    render json: current_resource_owner
  end
end
