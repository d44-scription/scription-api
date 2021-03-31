# frozen_string_literal: true

module Api
  module V1
    class LocationsController < ApiController
      before_action :fetch_notebook

      def index
        @locations = @notebook.locations.order(:name)

        @locations = @locations.where('UPPER("name") LIKE ?', "%#{params[:q].upcase}%") if params[:q]
      end

      private

      def fetch_notebook
        @notebook = current_user.notebooks.find(params[:notebook_id])
      end
    end
  end
end
