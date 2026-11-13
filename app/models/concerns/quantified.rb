# For records with a free-text `quantity`, a `unit` and a `name` (ingredients, grocery items).
module Quantified
  extend ActiveSupport::Concern

  def amount = Quantity.parse(quantity)

  # "2 tbsp olive oil", with the quantity scaled; free-text quantities ("a pinch") stay as written.
  def to_line(factor = 1)
    shown = amount ? Quantity.format(amount * factor) : quantity
    [ shown, unit, name ].compact_blank.join(" ")
  end
end
