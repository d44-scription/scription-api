# frozen_string_literal: true

json.partial! 'api/v1/notebooks/notebook', notebook: @notebook
json.notes @notebook.notes, partial: 'api/v1/notes/note', as: :note
