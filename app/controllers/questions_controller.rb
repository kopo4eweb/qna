# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[show update destroy subscribe]

  authorize_resource

  include Voted
  include Commented

  def index
    @questions = Question.all
  end

  def show
    @answers = @question.answers.with_attached_files.order(best: :desc, created_at: :desc)
    @answer = @question.answers.new
    @answer.links.build
    gon.question_id = @question.id
  end

  def new
    @question = Question.new
    @question.links.build
    @question.build_reward
  end

  def create
    @question = current_user.questions.new(question_params)
    if @question.save
      send_question('add')
      redirect_to @question, notice: 'Your question successfully created.'
    else
      render :new
    end
  end

  def update
    @question.update(question_params)
    send_question('update')
  end

  def destroy
    @question.destroy
    send_question('destroy')
    redirect_to questions_path, notice: "Question #{@question.title} delete."
  end

  def subscribe
    @subscription = @question.subscriptions.find_by(user: current_user)
    if @subscription
      @subscription.destroy
      flash.now[:alert] = 'You have unsubscribed to updates on this issue.'
    else
      @question.subscriptions.create(user: current_user)
      flash.now[:notice] = 'You have subscribed to updates on this issue.'
    end
  end

  private

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [],
                                                    links_attributes: %i[id name url _destroy],
                                                    reward_attributes: %i[id title image _destroy])
  end

  def send_question(event)
    return if @question.errors.any?

    result = {
      id: @question.id,
      event: event
    }

    if %w[add update].include?(event)
      result[:body] = ApplicationController.render(
        partial: 'questions/question',
        locals: { question: @question, current_user: nil }
      )
    end

    ActionCable.server.broadcast(
      'questions',
      result
    )
  end
end
