# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def destroy
    @file = ActiveStorage::Attachment.find(params[:id])

    authorize! :destroy, @file
    @file.record.touch
    @file.purge
    flash.now.notice = 'Your file removed.'
  end
end
