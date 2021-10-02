# frozen_string_literal: true

class AttachmentsController < ApplicationController
  def destroy
    @file = ActiveStorage::Attachment.find(params[:id])

    authorize! :destroy, @file
    # rubocop:disable Rails/SkipsModelValidations
    @file.record.touch
    # rubocop:enable Rails/SkipsModelValidations
    @file.purge
    flash.now.notice = 'Your file removed.'
  end
end
