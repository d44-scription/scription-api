# frozen_string_literal: true

json.extract! note, :id, :content, :notebook_id
json.success_message note.notable_message
