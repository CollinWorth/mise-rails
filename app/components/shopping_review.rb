# The ingredient checklist of the "Shop for this week" sheet. Pantry items start unticked.
# "Always have" adds a line to the pantry and redraws this frame in place (see MealPlans::PantryItemsController).
class Components::ShoppingReview < Components::Base
  # ticked: the keys to show ticked, or nil for the defaults (everything not in the pantry).
  def initialize(trip:, ticked: nil)
    @trip = trip
    @ticked = ticked
  end

  def view_template
    turbo_frame(id: "shop-ingredients") do
      lines = @trip.lines
      ActionForm(action: grocery_list_meal_plan_path, top: true) do
        Stack(gap: :sm) do
          input(type: :hidden, name: "date", value: @trip.week_start)
          input(type: :hidden, name: "meal_ids[]", value: "")
          @trip.selected_meals.each { |meal| input(type: :hidden, name: "meal_ids[]", value: meal.id) }
          input(type: :hidden, name: "ingredient_keys[]", value: "")
          Heading(level: 4) { "Ingredients" }
          lines.empty? ? Text { "Pick at least one meal." } : lines.each { |line| row(line) }
          Button(type: :submit, disabled: lines.empty?) { "Add ticked items to grocery list" }
        end
      end
    end
  end

  private
    def row(line)
      id = "ingredient_#{line.key.parameterize}"
      Row(gap: :sm, justify: :between) do
        Row(gap: :sm) do
          Checkbox(id:, name: "ingredient_keys[]", value: line.key, checked: ticked?(line))
          div do
            FormFieldLabel(for: id) { line.text }
            Text(class: "text-xs text-muted-foreground") { "from #{line.recipe_names.to_sentence}" }
          end
        end
        if line.in_pantry
          Badge(variant: :outline) { "in pantry" }
        else
          Button(type: :submit, variant: :ghost, size: :sm, formaction: grocery_list_meal_plan_pantry_items_path, name: "pantry_key", value: line.key,
                 data: { keep_open: true }) { "Always have" }
        end
      end
    end

    def ticked?(line) = @ticked ? @ticked.include?(line.key) : !line.in_pantry
end
