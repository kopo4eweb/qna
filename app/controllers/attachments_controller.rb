# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def destroy
    @file = ActiveStorage::Attachment.find(params[:id])

    if current_user&.author_of?(@file.record)
      @file.purge
      flash.now.notice = 'Your file removed.'
    else
      flash.now.alert = 'Not enough permissions'
    end
  end
end
