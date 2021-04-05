# frozen_string_literal: true

json.array! @notables, partial: 'api/v1/notables/notable', as: :notable
