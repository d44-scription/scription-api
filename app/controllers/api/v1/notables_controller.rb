# frozen_string_literal: true

module Api
  module V1
    class NotablesController < ApiController
      before_action :fetch_notebook
      before_action :fetch_notable, only: %i[notes show update destroy]

      def index
        @notables = @notebook.notables.order(:order_index)

        @notables = @notables.where('UPPER("name") LIKE ?', "%#{params[:q].upcase}%") if params[:q]
      end

      def notes
        @notes = @notable.notes.order(:order_index).uniq
      end

      def recents
        @notables = @notebook.notables.order(viewed_at: :desc).first(5)
      end

      def show
        @notable.update(viewed_at: DateTime.now)
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
        @notebook = current_user.notebooks.find(params[:notebook_id])
      end

      def fetch_notable
        @notable = @notebook.notables.find(params[:id])
      end

      def notable_params
        params.require(:notable).permit(:name, :description, :type, :notebook_id)
      end
    end
  end
end
