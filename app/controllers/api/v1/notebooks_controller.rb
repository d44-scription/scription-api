# frozen_string_literal: true

module Api
  module V1
    class NotebooksController < ApplicationController
      before_action :fetch_notebook, only: %i[show update destroy]

      def index
        @notebooks = Notebook.all.order(:order_index)
      end

      def create
        @notebook = Notebook.new(notebook_params)

        if @notebook.save
          render :show, status: :created
        else
          render json: @notebook.errors.full_messages, status: :unprocessable_entity
        end
      end

      def update
        if @notebook.update(notebook_params)
          render :show, status: :ok
        else
          render json: @notebook.errors.full_messages, status: :unprocessable_entity
        end
      end

      def destroy
        @notebook.destroy
      end

      private

      def fetch_notebook
        @notebook = Notebook.find(params[:id])
      end

      def notebook_params
        params.require(:notebook).permit(:name, :summary)
      end
    end
  end
end
