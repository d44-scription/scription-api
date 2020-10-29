# frozen_string_literal: true

json.extract! item, :id, :name, :description, :notebook_id, :created_at, :updated_at
json.url notebook_notable_url(@notebook, item, format: :json)
