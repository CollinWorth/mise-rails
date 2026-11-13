# The ingredient checklist of the planner's "Add to grocery list" sheet. Pantry items start unticked.
# "Add to pantry" / "Remove from pantry" change the pantry and redraw this frame in place (see MealPlans::PantryItemsController).
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
      Row(gap: :sm, class: "flex-nowrap") do
        Checkbox(id:, name: "ingredient_keys[]", value: line.key, checked: ticked?(line))
        div(class: "min-w-0 flex-1") do
          FormFieldLabel(for: id, class: "flex cursor-pointer justify-between gap-3 leading-snug") do
            span(class: "truncate") { line.name }
            plain " "
            span(class: "shrink-0 font-normal text-muted-foreground") { line.amount_text }
          end
          p(class: "truncate text-xs leading-snug text-muted-foreground", title: source_text(line)) { source_text(line) }
        end
        pantry_button(line)
      end
    end

    def source_text(line) = [ ("In your pantry" if line.in_pantry), "from #{line.recipe_names.to_sentence}" ].compact.join(" · ")

    # Adds the ingredient to the pantry, or, if it is there already, takes it out again. Both redraw this frame in place.
    def pantry_button(line)
      if line.in_pantry
        Button(type: :submit, variant: :ghost, size: :sm, class: "shrink-0 whitespace-nowrap text-xs", formaction: grocery_list_meal_plan_pantry_item_path(line.key), formmethod: "delete",
               aria: { label: "Remove #{line.name} from pantry" }, data: { keep_open: true }) { "Remove from pantry" }
      else
        Button(type: :submit, variant: :ghost, size: :sm, class: "shrink-0 whitespace-nowrap text-xs", formaction: grocery_list_meal_plan_pantry_items_path, name: "pantry_key", value: line.key,
               aria: { label: "Add #{line.name} to pantry" }, data: { keep_open: true }) { "Add to pantry" }
      end
    end

    def ticked?(line) = @ticked ? @ticked.include?(line.key) : !line.in_pantry
end
