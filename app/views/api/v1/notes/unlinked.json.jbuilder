# frozen_string_literal: true

json.array! @notes, partial: 'api/v1/notes/note', as: :note
