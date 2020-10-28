# frozen_string_literal: true

class NotesController < ApplicationController
  before_action :fetch_notebook
  before_action :fetch_note, only: %i[show update destroy]

  def index
    @notes = Note.all
  end

  def create
    @note = Note.new(note_params)

    if @note.save
      render :show, status: :created, location: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(note_params)
      render :show, status: :ok, location: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
  end

  private

  def fetch_notebook
    @notebook = Notebook.find(params[:notebook_id])
  end

  def fetch_note
    @note = @notebook.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:contents, :notebook_id)
  end
end
