# frozen_string_literal: true

class LinksController < ApplicationController
  def destroy
    @link = Link.find(params[:id])

    if current_user&.author_of?(@link.linkable)
      @link.destroy
      flash.now.notice = 'Your link removed.'
    else
      flash.now.alert = 'Not enough permissions'
    end
  end
end
