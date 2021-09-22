# frozen_string_literal: true

class SearchController < ApplicationController
  skip_authorization_check

  def search
    @query = params[:query]
    @resource = params[:resource]
    @search_result = model_klass(@resource).search(@query, page: params[:page], per_page: 10) if @query
  end

  private

  def model_klass(class_name)
    class_name == 'all' ? ThinkingSphinx : class_name.classify.constantize
  end
end
