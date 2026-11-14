# A recipe's place in a collection. Cooks can collect their own recipes and any public one.
class CollectionRecipe < ApplicationRecord
  belongs_to :collection
  belongs_to :recipe

  validates :recipe_id, uniqueness: { scope: :collection_id }
  validate :recipe_is_visible_to_the_owner

  private
    def recipe_is_visible_to_the_owner
      errors.add(:recipe, "isn't available to add") unless recipe && Recipe.visible_to(collection.user).exists?(recipe.id)
    end
end
