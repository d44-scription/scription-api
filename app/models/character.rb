# frozen_string_literal: true

class Character < Notable
  TRIGGER = '@'

  def text_code
    "#{TRIGGER}[#{name}](#{TRIGGER}#{id})"
  end
end
