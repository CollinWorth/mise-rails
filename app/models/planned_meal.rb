# Something planned for a day: a recipe, or a note, which is just words ("Leftovers", "Eating out") and has no recipe.
class PlannedMeal < ApplicationRecord
  belongs_to :user
  belongs_to :recipe, optional: true

  normalizes :title, with: ->(title) { title.to_s.squish.presence }

  validates :date, presence: true
  validates :multiplier, numericality: { only_integer: true, greater_than: 0 }
  validates :title, presence: { message: "can't be blank for something that isn't a recipe" }, unless: :recipe
  validates :title, length: { maximum: 80 }

  scope :between, ->(range) { where(date: range) }
  scope :with_recipe, -> { where.not(recipe_id: nil) }

  def note? = recipe.nil?
  def name = recipe&.name || title
end
