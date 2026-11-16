class GroceryItem < ApplicationRecord
  # Aisle order and keywords live in config/grocery_categories.yml
  CATEGORIES = YAML.load_file(Rails.root.join("config/grocery_categories.yml")).freeze

  include Quantified

  belongs_to :grocery_list
  has_many :sources, -> { order(:planned_on, :id) }, class_name: "GroceryItemSource", dependent: :destroy

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES.keys }

  before_validation :guess_category, if: :guess_category?

  # The longest keyword found as a whole word in the name wins, so "tomato paste" beats "tomato".
  def self.categorize(name)
    name = name.to_s.downcase
    matches = CATEGORIES.flat_map { |key, config| config["keywords"].select { |word| name.match?(/(?:\A|\s)#{Regexp.escape(word)}(?:e?s)?(?:\s|,|\z)/) }.map { |word| [ key, word ] } }
    matches.max_by { |_, word| word.length }&.first || "other"
  end

  private
    # New items go to the aisle their name suggests, and so do renamed ones, unless the item was moved somewhere else by hand.
    def guess_category?
      return category.blank? || category == "other" if new_record?

      category.blank? || (name_changed? && !category_changed? && category == self.class.categorize(name_was))
    end

    def guess_category
      self.category = self.class.categorize(name)
    end
end
