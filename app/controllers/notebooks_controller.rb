# frozen_string_literal: true

class NotebooksController < ApplicationController
  before_action :set_notebook, only: %i[show update destroy]

  # GET /notebooks
  # GET /notebooks.json
  def index
    @notebooks = Notebook.all
  end

  # GET /notebooks/1
  # GET /notebooks/1.json
  def show; end

  # POST /notebooks
  # POST /notebooks.json
  def create
    @notebook = Notebook.new(notebook_params)

    if @notebook.save
      render :show, status: :created, location: @notebook
    else
      render json: @notebook.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notebooks/1
  # PATCH/PUT /notebooks/1.json
  def update
    if @notebook.update(notebook_params)
      render :show, status: :ok, location: @notebook
    else
      render json: @notebook.errors, status: :unprocessable_entity
    end
  end

  # DELETE /notebooks/1
  # DELETE /notebooks/1.json
  def destroy
    @notebook.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_notebook
    @notebook = Notebook.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def notebook_params
    params.require(:notebook).permit(:name)
  end
end
