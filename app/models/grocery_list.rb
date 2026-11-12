class GroceryList < ApplicationRecord
  belongs_to :user
  has_many :items, -> { order(:checked, :category, :name) }, class_name: "GroceryItem", dependent: :destroy

  # Adds every ingredient of the given meals, scaling by multiplier and merging
  # with items already on the list. Returns how many items were added or merged.
  def add_meals(planned_meals)
    add_recipes(planned_meals.includes(recipe: :ingredients).map { |meal| [ meal.recipe, meal.multiplier ] })
  end

  # Same for [recipe, multiplier] pairs, e.g. one recipe at 2x.
  def add_recipes(recipes_with_multipliers)
    needed = Hash.new { |hash, name| hash[name] = { amount: 0r, unit: nil, text: nil } }

    recipes_with_multipliers.each do |recipe, multiplier|
      recipe.ingredients.reject(&:section).each do |ingredient|
        entry = needed[ingredient.name.strip.downcase]
        entry[:unit] ||= ingredient.unit
        if (amount = ingredient.amount)
          entry[:amount] += amount * multiplier
        else
          entry[:text] ||= ingredient.quantity
        end
      end
    end

    needed.each { |name, entry| merge_item(name, entry) }.size
  end

  private
    def merge_item(name, entry)
      item = items.find_or_initialize_by(name:)
      total = (item.amount || 0r) + entry[:amount]
      item.quantity = total.zero? ? entry[:text] : Quantity.format(total)
      item.unit ||= entry[:unit]
      item.save!
    end
end
