# frozen_string_literal: true

module Api::V1
  class ItemsController < ApplicationController
    before_action :fetch_notebook

    def index
      @items = @notebook.items
    end

    private

    def fetch_notebook
      @notebook = Notebook.find(params[:notebook_id])
    end
  end
end
