# A time someone cooked a recipe. The recipe link goes away if the recipe is deleted; the name stays.
class Cooking < ApplicationRecord
  UNDO_WINDOW = 1.day

  belongs_to :user
  belongs_to :recipe, optional: true

  before_validation { self.recipe_name ||= recipe&.name }
  before_validation { self.cooked_at ||= Time.current }

  validates :recipe_name, presence: true

  scope :newest, -> { order(cooked_at: :desc, id: :desc) }

  # Mistaken taps can be taken back for a day; after that it's history.
  def undoable? = cooked_at > UNDO_WINDOW.ago
end
