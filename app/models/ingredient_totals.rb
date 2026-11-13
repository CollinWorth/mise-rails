# Totals the ingredients of [recipe, multiplier, planned_on] groups into one entry per ingredient
# (matched on IngredientName.normalize), scaling quantities and remembering what each recipe contributed.
# Units that can't be merged (weight vs. volume, or ones the app doesn't know) become separate entries.
class IngredientTotals
  Source = Struct.new(:recipe, :planned_on, :unit, :amount, :text, keyword_init: true)

  # key identifies one line; name_key is the ingredient alone (for pantry matching) and group the kind of unit.
  Entry = Struct.new(:key, :name_key, :group, :name, :sources, keyword_init: true) do
    def amount = total.first
    def unit = total.last
    def text = sources.filter_map(&:text).first
    def recipe_names = sources.map { |source| source.recipe.name }.uniq

    def to_line
      [ (amount.zero? ? text : Quantity.format(amount)), unit, name ].compact_blank.join(" ")
    end

    private
      def total
        @total ||= begin
          parts = sources.filter_map { |source| [ source.amount, source.unit ] if source.amount }
          parts.any? ? Units.total(parts) : [ 0r, sources.first.unit ]
        end
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
        name_key = IngredientName.normalize(ingredient.name)
        next if name_key.blank?

        group = Units.group(ingredient.unit)
        key = group.empty? ? name_key : "#{name_key}|#{group}"
        entry = (@entries[key] ||= Entry.new(key:, name_key:, group:, name: ingredient.name.strip.downcase, sources: []))
        source = (sources[[ key, Units.find(ingredient.unit)&.name ]] ||= Source.new(recipe:, planned_on:, unit: ingredient.unit, amount: nil, text: nil).tap { |created| entry.sources << created })
        if (amount = ingredient.amount)
          source.amount = (source.amount || 0r) + amount * multiplier
        else
          source.text ||= ingredient.quantity
        end
      end
    end
end
