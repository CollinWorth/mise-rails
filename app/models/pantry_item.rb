# Something this user always has (salt, olive oil, ...). Matching ingredients are left off new grocery lists.
class PantryItem < ApplicationRecord
  # Offered on an empty pantry page, one tap each. Everyone's pantry differs, so nothing is added automatically.
  SUGGESTIONS = [ "water", "salt", "black pepper", "olive oil", "vegetable oil", "flour", "sugar", "butter" ].freeze

  belongs_to :user

  before_validation { self.name = name.to_s.squish; self.normalized_name = IngredientName.normalize(name) }

  validates :name, :normalized_name, presence: true
  validates :normalized_name, uniqueness: { scope: :user_id, message: "is already in your pantry" }
end
