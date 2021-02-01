# frozen_string_literal: true

json.extract! note, :id, :content, :notebook_id, :order_index, :created_at, :updated_at
json.success_message note.notable_message
json.url api_v1_notebook_note_url(@notebook, note, format: :json)
