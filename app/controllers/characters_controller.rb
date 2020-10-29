# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :fetch_notebook

  def index
    @characters = @notebook.characters
  end

  private

  def fetch_notebook
    @notebook = Notebook.find(params[:notebook_id])
  end
end
