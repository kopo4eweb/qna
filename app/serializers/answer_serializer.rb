# frozen_string_literal: true

class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at, :updated_at

  belongs_to :question
  belongs_to :user
  has_many :comments
  has_many :links
  has_many :files, each_serializer: AttachmentSerializer
end
