# frozen_string_literal: true

json.extract! notable, :id, :name, :description, :type, :notebook_id, :order_index, :created_at, :updated_at
json.url api_v1_notebook_notable_url(@notebook, notable, format: :json)
