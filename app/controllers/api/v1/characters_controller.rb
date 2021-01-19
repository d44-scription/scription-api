# frozen_string_literal: true

module Api
  module V1
    class CharactersController < ApplicationController
      before_action :fetch_notebook

      def index
        @characters = @notebook.characters

        @characters = @characters.where('UPPER("name") LIKE ?', "%#{params[:q].upcase}%") if params[:q]
      end

      private

      def fetch_notebook
        @notebook = Notebook.find(params[:notebook_id])
      end
    end
  end
end
