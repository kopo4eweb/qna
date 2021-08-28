# frozen_string_literal: true

module Voted
  extend ActiveSupport::Concern

  included do
    before_action :find_votable, only: %i[vote_up vote_down cancel_vote]
  end

  def vote_up
    @votable.vote_up(current_user)
    respond_votable
  end

  def vote_down
    @votable.vote_down(current_user)
    respond_votable
  end

  def cancel_vote
    @votable.cancel_vote(current_user)
    respond_votable
  end

  private

  def respond_votable
    respond_to do |format|
      if @votable.save
        format.json do
          render json: { id: @votable.id, resource: @votable.class.name.underscore, total_votes: @votable.total_votes }
        end
      else
        format.json { render json: @votable.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def model_klass
    controller_name.classify.constantize
  end

  def find_votable
    @votable = model_klass.find(params[:id])
  end
end
