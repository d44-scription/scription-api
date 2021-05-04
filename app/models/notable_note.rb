class NotableNote < ApplicationRecord
  belongs_to :note
  belongs_to :notable
end
