# frozen_string_literal: true
partial_reference = @notable.type.downcase
json.partial! "api/v1/#{partial_reference}s/#{partial_reference}", notable: @notable
