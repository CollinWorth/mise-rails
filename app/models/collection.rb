# A named group of recipes. Private unless public; a public one is on its cook's profile and open to anyone with the link, but
# what a visitor sees inside it is still only the recipes they may see anyway.
class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_recipes, dependent: :destroy
  has_many :recipes, through: :collection_recipes

  normalizes :name, with: ->(name) { name.to_s.squish }
  normalizes :description, with: ->(text) { text.to_s.strip.presence }

  validates :name, presence: true, length: { maximum: 60 }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :description, length: { maximum: 300 }

  scope :published, -> { where(public: true) }
  scope :visible_to, ->(user) { where(public: true).or(where(user:)) }
  scope :newest, -> { order(id: :desc) }

  # The recipes in it that this viewer may see, the most recently added first.
  def recipes_for(viewer) = recipes.visible_to(viewer).reorder("collection_recipes.created_at DESC", "collection_recipes.id DESC")

  # A recipe with a photo to stand for the collection.
  def cover_recipe(viewer) = recipes_for(viewer).joins(:image_attachment).with_attached_image.first

  def add(recipe) = collection_recipes.find_or_create_by!(recipe:)
  def remove(recipe) = collection_recipes.where(recipe:).destroy_all
  def includes?(recipe) = collection_recipes.exists?(recipe:)
end
