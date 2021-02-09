# frozen_string_literal: true

module Api
  module V1
    class LocationsController < ApiController
      before_action :fetch_notebook

      def index
        @locations = @notebook.locations.order(:order_index)

        @locations = @locations.where('UPPER("name") LIKE ?', "%#{params[:q].upcase}%") if params[:q]
      end

      private

      def fetch_notebook
        @notebook = Notebook.find(params[:notebook_id])
      end
    end
  end
end
