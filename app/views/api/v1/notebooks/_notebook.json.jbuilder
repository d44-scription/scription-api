# frozen_string_literal: true

json.extract! notebook, :id, :name, :summary, :created_at, :updated_at
json.url api_v1_notebook_url(notebook, format: :json)
