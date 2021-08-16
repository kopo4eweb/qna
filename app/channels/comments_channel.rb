# frozen_string_literal: true

class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "comments/question-#{params[:question_id]}"
  end
end
