# frozen_string_literal: true

json.partial! 'notebooks/notebook', notebook: @notebook
json.notes @notebook.notes, partial: 'notes/note', as: :note
