# frozen_string_literal: true

json.extract! user, :id, :email, :display_name, :created_at, :updated_at
json.token note.generate_jwt
