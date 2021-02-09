# frozen_string_literal: true

module Api
  module V1
    class ItemsController < ApiController
      before_action :fetch_notebook

      def index
        @items = @notebook.items.order(:order_index)

        @items = @items.where('UPPER("name") LIKE ?', "%#{params[:q].upcase}%") if params[:q]
      end

      private

      def fetch_notebook
        @notebook = Notebook.find(params[:notebook_id])
      end
    end
  end
end
