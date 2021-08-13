# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_question, only: :create
  before_action :find_answer, only: %I[update select_best destroy]
  before_action :answer_author?, only: %I[update destroy]
  before_action :question_author?, only: :select_best

  include Voted
  include Commented

  def create
    @answer = @question.answers.create(answer_params.merge(user: current_user))
    send_answer('add')
  end

  def update
    @answer.update(answer_params)
    send_answer('update')
  end

  def select_best
    @answer.switch_best
    send_answer('update')
  end

  def destroy
    @answer.destroy
    send_answer('destroy')
    flash.now.notice = 'Your answer removed.'
  end

  private

  def question_author?
    author?(@answer.question)
  end

  def answer_author?
    author?(@answer)
  end

  def author?(resource)
    return if current_user&.author_of?(resource)

    flash.now.alert = 'Not enough permissions'
    redirect_to question_path(@answer.question)
  end

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: %i[id name url _destroy])
  end

  def send_answer(event)
    return if @answer.errors.any?

    result = {
      id: @answer.id,
      question_id: @answer.question_id,
      event: event,
      author_id: current_user.id
    }

    if %w[add update].include?(event)
      result[:body] = ApplicationController.render(
        partial: 'answers/answer',
        locals: { answer: @answer, current_user: nil }
      )
    end

    ActionCable.server.broadcast(
      "questions/#{@answer.question_id}",
      result
    )
  end
end
