# The "shop for this week" review: a week of planned meals, which of them are included,
# and the merged ingredient lines they add up to (flagged when they're already in the pantry).
class ShoppingTrip
  Line = Struct.new(:key, :name_key, :name, :text, :recipe_names, :in_pantry, keyword_init: true)

  attr_reader :week_start

  # meal_ids: the ids of the meals to include, or nil for all of the week's meals.
  def initialize(user:, week_start:, meal_ids: nil)
    @user = user
    @week_start = week_start
    @meal_ids = meal_ids&.map(&:to_s)
  end

  def meals
    @meals ||= @user.planned_meals.between(week_start..week_start + 6).includes(recipe: :ingredients).order(:date, :id).to_a
  end

  def selected_meals = @meal_ids ? meals.select { |meal| @meal_ids.include?(meal.id.to_s) } : meals
  def selected?(meal) = selected_meals.include?(meal)

  def totals = @totals ||= IngredientTotals.new(selected_meals.map { |meal| [ meal.recipe, meal.multiplier, meal.date ] })

  def lines
    pantry = @user.pantry_keys
    totals.map do |entry|
      Line.new(key: entry.key, name_key: entry.name_key, name: entry.name, text: entry.to_line, recipe_names: entry.recipe_names, in_pantry: pantry.include?(entry.name_key))
    end
  end

  def title = "#{week_start.strftime('%b %-d')} – #{(week_start + 6).strftime('%b %-d')}"
end
