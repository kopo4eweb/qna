# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[show update destroy]
  before_action :question_author?, only: %i[update destroy]

  def index
    @questions = Question.all
  end

  def show
    @answers = @question.answers.order(best: :desc, created_at: :desc)
    @answer = @question.answers.new
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.new(question_params)
    if @question.save
      redirect_to @question, notice: 'Your question successfully created.'
    else
      render :new
    end
  end

  def update
    @question.update(question_params)
  end

  def destroy
    @question.destroy
    redirect_to questions_path, notice: "Question #{@question.title} delete."
  end

  private

  def question_author?
    redirect_to @question, alert: 'Not enough permissions' unless current_user&.author_of?(@question)
  end

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [])
  end
end
