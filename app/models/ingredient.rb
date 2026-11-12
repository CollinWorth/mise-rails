class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true

  def amount = Quantity.parse(quantity)
end
