# Ingredient quantities are free text ("1 1/2", "½"). This turns them into
# Rationals so they can be summed, and back into readable text.
module Quantity
  UNICODE = { "½" => "1/2", "¼" => "1/4", "¾" => "3/4", "⅓" => "1/3", "⅔" => "2/3", "⅛" => "1/8" }.freeze

  def self.parse(text)
    text = UNICODE.reduce(text.to_s) { |memo, (char, fraction)| memo.gsub(char, " #{fraction}") }
    parts = text.split
    return if parts.empty?
    parts.sum { |part| Rational(part) }
  rescue ArgumentError, ZeroDivisionError
    nil
  end

  def self.format(rational)
    whole, remainder = rational.divmod(1)
    fraction = remainder.zero? ? nil : "#{remainder.numerator}/#{remainder.denominator}"
    [ (whole unless whole.zero? && fraction), fraction ].compact.join(" ")
  end
end
