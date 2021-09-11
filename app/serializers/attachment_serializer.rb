# frozen_string_literal: true

class AttachmentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :file_url

  def file_url
    rails_blob_path(object, only_path: true)
  end
end
