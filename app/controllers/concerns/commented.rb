# frozen_string_literal: true

module Commented
  extend ActiveSupport::Concern

  included do
    before_action :find_commentable, only: :add_comment
    after_action :publish_comment, only: :add_comment
  end

  def add_comment
    @comment = @commentable.comments.create(comment_params.merge(user: current_user))

    respond_to do |format|
      format.js do
        render partial: 'comments/add_comment', layout: false
      end
    end
  end

  private

  def publish_comment
    return if @comment.errors.any?

    result = {
      resource_id: @commentable.id,
      type: controller_name.classify.downcase,
      author_id: current_user.id
    }

    result[:body] = ApplicationController.render(
      partial: 'comments/comment',
      locals: { comment: @comment }
    )

    ActionCable.server.broadcast(
      "comments/question-#{@commentable.is_a?(Question) ? @commentable.id : @commentable.question.id}",
      result
    )
  end

  def model_klass
    controller_name.classify.constantize
  end

  def find_commentable
    @commentable = model_klass.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
