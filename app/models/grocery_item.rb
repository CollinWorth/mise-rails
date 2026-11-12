class GroceryItem < ApplicationRecord
  # Aisle order and keywords live in config/grocery_categories.yml
  CATEGORIES = YAML.load_file(Rails.root.join("config/grocery_categories.yml")).freeze

  belongs_to :grocery_list

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES.keys }

  before_validation :guess_category, on: :create

  def amount = Quantity.parse(quantity)

  # The longest keyword found as a whole word in the name wins, so "tomato paste" beats "tomato".
  def self.categorize(name)
    name = name.to_s.downcase
    matches = CATEGORIES.flat_map { |key, config| config["keywords"].select { |word| name.match?(/(?:\A|\s)#{Regexp.escape(word)}(?:e?s)?(?:\s|,|\z)/) }.map { |word| [ key, word ] } }
    matches.max_by { |_, word| word.length }&.first || "other"
  end

  private
    def guess_category
      self.category = self.class.categorize(name) if category.blank? || category == "other"
    end
end
