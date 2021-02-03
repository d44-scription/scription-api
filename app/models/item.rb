# frozen_string_literal: true

class Item < Notable
  TRIGGER = ':'

  def text_code
    "#{TRIGGER}[#{name}](#{TRIGGER}#{id}))"
  end
end
