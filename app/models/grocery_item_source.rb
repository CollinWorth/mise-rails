# One recipe's (or planned meal's) contribution to a grocery item, so you can see
# where an item came from and how much each meal needed.
class GroceryItemSource < ApplicationRecord
  belongs_to :grocery_item
  belongs_to :recipe, optional: true # the recipe may have been deleted since

  def to_line(item_name) = [ quantity, unit, item_name ].compact_blank.join(" ")
end
