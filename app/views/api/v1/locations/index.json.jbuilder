# frozen_string_literal: true

json.array! @locations, partial: 'api/v1/locations/location', as: :notable
