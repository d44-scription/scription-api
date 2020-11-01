# frozen_string_literal: true

module Api
  module V1
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
  end
end
