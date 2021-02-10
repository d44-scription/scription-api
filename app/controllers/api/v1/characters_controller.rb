# frozen_string_literal: true

module Api
  module V1
    class CharactersController < ApiController
      before_action :fetch_notebook

      def index
        @characters = @notebook.characters.order(:order_index)

        @characters = @characters.where('UPPER("name") LIKE ?', "%#{params[:q].upcase}%") if params[:q]
      end

      private

      def fetch_notebook
        @notebook = current_user.notebooks.find(params[:notebook_id])
      end
    end
  end
end
