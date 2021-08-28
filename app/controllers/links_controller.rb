# frozen_string_literal: true

class LinksController < ApplicationController
  def destroy
    @link = Link.find(params[:id])

    authorize! :destroy, @link
    @link.destroy
    flash.now.notice = 'Your link removed.'
  end
end
