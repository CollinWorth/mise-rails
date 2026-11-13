class GroceryList < ApplicationRecord
  belongs_to :user
  has_many :items, -> { order(:checked, :category, :name) }, class_name: "GroceryItem", dependent: :destroy

  # What an add did, for the message shown afterwards.
  Result = Data.define(:added, :in_pantry) do
    def summary
      note = " (#{in_pantry} already in your pantry)" if in_pantry.positive?
      return "Nothing to add#{note}." if added.zero?

      "Added #{added} #{'item'.pluralize(added)}#{note}."
    end
  end

  # Adds every ingredient of the given meals, scaling by multiplier and merging
  # with items already on the list.
  def add_meals(planned_meals, only: nil)
    add_recipes(planned_meals.map { |meal| [ meal.recipe, meal.multiplier, meal.date ] }, only:)
  end

  # Same for [recipe, multiplier] or [recipe, multiplier, planned_on] groups, e.g. one recipe at 2x.
  # `only` is a list of ingredient keys the user picked; without it, everything except pantry items is added.
  def add_recipes(groups, only: nil)
    pantry = only ? [] : user.pantry_keys
    added = in_pantry = 0

    IngredientTotals.new(groups).each do |entry|
      next if only && !only.include?(entry.key)

      if pantry.include?(entry.name_key)
        in_pantry += 1
      else
        merge_item(entry)
        added += 1
      end
    end

    Result.new(added:, in_pantry:)
  end

  private
    # Adds to an item that's the same ingredient in a unit it can merge with, otherwise starts a new item.
    def merge_item(entry)
      item = items.detect { |existing| IngredientName.normalize(existing.name) == entry.name_key && Units.group(existing.unit) == entry.group } || items.build(name: entry.name)
      parts = [ ([ item.amount, item.unit ] if item.amount), ([ entry.amount, entry.unit ] if entry.amount.positive?) ].compact
      if parts.any?
        amount, unit = Units.total(parts)
        item.quantity = Quantity.format(amount)
        item.unit = unit
      else
        item.quantity = entry.text || item.quantity
        item.unit ||= entry.unit
      end
      item.save!
      entry.sources.each do |source|
        item.sources.create!(recipe: source.recipe, recipe_name: source.recipe.name, planned_on: source.planned_on,
                             quantity: (Quantity.format(source.amount) if source.amount) || source.text, unit: source.unit)
      end
    end
end
