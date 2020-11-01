# frozen_string_literal: true

json.array! @notebooks, partial: 'api/v1/notebooks/notebook', as: :notebook
