# frozen_string_literal: true

class AnswersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "questions/#{params[:question_id]}"
  end
end
