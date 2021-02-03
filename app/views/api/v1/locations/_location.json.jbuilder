# frozen_string_literal: true

json.extract! notable, :id, :name, :description, :notebook_id, :order_index, :text_code, :created_at, :updated_at
json.url api_v1_notebook_notable_url(@notebook, notable, format: :json)
