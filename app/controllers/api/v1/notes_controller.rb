# frozen_string_literal: true

module Api
  module V1
    class NotesController < ApiController
      before_action :fetch_notebook
      before_action :fetch_note, only: %i[show update destroy]

      def index
        @notes = @notebook.notes.order(:order_index)
      end

      def unlinked
        @notes = @notebook.notes.where.missing(:notables).order(:order_index)
      end

      def create
        @note = @notebook.notes.new(note_params)

        if @note.save
          render :show, status: :created
        else
          render json: @note.errors.full_messages, status: :unprocessable_entity
        end
      end

      def update
        if @note.update(note_params)
          render :show, status: :ok
        else
          render json: @note.errors.full_messages, status: :unprocessable_entity
        end
      end

      def destroy
        @note.destroy
      end

      private

      def fetch_notebook
        @notebook = current_user.notebooks.find(params[:notebook_id])
      end

      def fetch_note
        @note = @notebook.notes.find(params[:id])
      end

      def note_params
        params.require(:note).permit(:content, :notebook_id)
      end
    end
  end
end
