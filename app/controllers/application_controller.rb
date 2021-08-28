# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :gon_user

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to root_path, alert: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  check_authorization unless: :devise_controller?

  private

  def gon_user
    gon.current_user_id = current_user.id if signed_in?
  end
end
