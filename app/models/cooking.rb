# A day someone cooked a recipe. The recipe link goes away if the recipe is deleted; the name stays.
class Cooking < ApplicationRecord
  UNDO_DAYS = 1

  belongs_to :user
  belongs_to :recipe, optional: true

  before_validation { self.recipe_name ||= recipe&.name }
  before_validation { self.cooked_on ||= Date.current }

  validates :recipe_name, presence: true

  scope :newest, -> { order(cooked_on: :desc, id: :desc) }

  # Mistaken taps can be taken back today or tomorrow; after that it's history.
  def undoable? = cooked_on >= Date.current - UNDO_DAYS
end
