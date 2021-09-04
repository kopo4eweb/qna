# frozen_string_literal: true

class Api::V1::QuestionsController < Api::V1::BaseController
  def index
    authorize! :read, Question
    render json: Question.all.to_json(include: :answers)
  end
end
