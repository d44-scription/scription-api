# frozen_string_literal: true

json.array! @notebooks, partial: 'notebooks/notebook', as: :notebook
