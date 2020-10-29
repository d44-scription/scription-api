# frozen_string_literal: true

json.extract! notable, :id, :name, :description, :type, :notebook_id, :created_at, :updated_at
json.url notebook_notable_url(@notebook, notable, format: :json)
