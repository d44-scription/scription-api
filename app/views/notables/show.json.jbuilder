# frozen_string_literal: true
partial_reference = @notable.type.downcase
json.partial! "#{partial_reference}s/#{partial_reference}", notable: @notable
