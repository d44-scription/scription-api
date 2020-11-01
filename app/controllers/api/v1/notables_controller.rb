# frozen_string_literal: true

module Api::V1
  class NotablesController < ApplicationController
    before_action :fetch_notebook
    before_action :fetch_notable, only: %i[show update destroy]

    def index
      @notables = @notebook.notables.order(:type)
    end

    def create
      @notable = @notebook.notables.new(notable_params)

      if @notable.save
        render :show, status: :created
      else
        render json: @notable.errors.full_messages, status: :unprocessable_entity
      end
    end

    def update
      if @notable.update(notable_params)
        render :show, status: :ok
      else
        render json: @notable.errors.full_messages, status: :unprocessable_entity
      end
    end

    def destroy
      @notable.destroy
    end

    private

    def fetch_notebook
      @notebook = Notebook.find(params[:notebook_id])
    end

    def fetch_notable
      @notable = @notebook.notables.find(params[:id])
    end

    def notable_params
      params.require(:notable).permit(:name, :description, :type, :notebook_id)
    end
  end
end
