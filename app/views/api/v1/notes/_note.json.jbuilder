# frozen_string_literal: true

json.extract! note, :id, :content, :notebook_id, :created_at, :updated_at
json.url api_v1_notebook_note_url(@notebook, note, format: :json)