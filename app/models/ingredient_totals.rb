# Totals the ingredients of [recipe, multiplier, planned_on] groups into one entry per ingredient
# (matched on IngredientName.normalize), scaling quantities and remembering what each recipe contributed.
class IngredientTotals
  Source = Struct.new(:recipe, :planned_on, :unit, :amount, :text, keyword_init: true)

  Entry = Struct.new(:key, :name, :unit, :sources, keyword_init: true) do
    def amount = sources.sum(0r) { |source| source.amount || 0 }
    def text = sources.filter_map(&:text).first
    def recipe_names = sources.map { |source| source.recipe.name }.uniq

    def to_line
      [ (amount.zero? ? text : Quantity.format(amount)), unit, name ].compact_blank.join(" ")
    end
  end

  include Enumerable

  def initialize(groups)
    @entries = {}
    groups.each { |recipe, multiplier, planned_on| add(recipe, multiplier, planned_on) }
  end

  def each(&) = @entries.each_value(&)
  def [](key) = @entries[key]

  private
    def add(recipe, multiplier, planned_on)
      sources = {}
      recipe.ingredients.reject(&:section?).each do |ingredient|
        key = IngredientName.normalize(ingredient.name)
        next if key.blank?

        entry = (@entries[key] ||= Entry.new(key:, name: ingredient.name.strip.downcase, unit: ingredient.unit, sources: []))
        entry.unit ||= ingredient.unit
        source = (sources[key] ||= Source.new(recipe:, planned_on:, unit: ingredient.unit, amount: nil, text: nil).tap { |created| entry.sources << created })
        if (amount = ingredient.amount)
          source.amount = (source.amount || 0r) + amount * multiplier
        else
          source.text ||= ingredient.quantity
        end
      end
    end
end
