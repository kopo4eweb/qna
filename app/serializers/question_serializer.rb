# frozen_string_literal: true

class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :created_at, :updated_at

  belongs_to :user
  has_many :answers
  has_many :comments
  has_many :links
  has_many :files, each_serializer: AttachmentSerializer
end
