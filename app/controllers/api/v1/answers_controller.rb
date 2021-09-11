# frozen_string_literal: true

class Api::V1::AnswersController < Api::V1::BaseController
  before_action :answer, only: %i[show update destroy]

  authorize_resource class: Answer

  def index
    @answers = Answer.where(question_id: params[:question_id])
    render json: @answers
  end

  def show
    render json: answer
  end

  def create
    @answer = current_resource_owner.answers.new(answer_params.merge(question_id: params[:question_id]))

    if @answer.save
      render json: @answer
    else
      render json: { errors: @answer.errors }, status: :unprocessable_entity
    end
  end

  def update
    if answer.update(answer_params)
      render json: answer
    else
      render json: { errors: answer.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if answer.destroy
      render json: answer
    else
      render json: { errors: answer.errors }, status: :unprocessable_entity
    end
  end

  private

  def answer
    @answer ||= Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
