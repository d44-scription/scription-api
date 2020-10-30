# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :fetch_notebook

  def index
    @locations = @notebook.locations
  end

  private

  def fetch_notebook
    @notebook = Notebook.find(params[:notebook_id])
  end
end
