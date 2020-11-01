# frozen_string_literal: true

json.extract! notable, :id, :name, :description, :notebook_id, :created_at, :updated_at
json.url api_v1_notebook_notable_url(@notebook, notable, format: :json)
