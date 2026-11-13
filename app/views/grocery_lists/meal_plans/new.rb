# The sheet behind the planner's "Add to grocery list" button: pick the meals, then pick the ingredients.
class Views::GroceryLists::MealPlans::New < Views::Base
  def initialize(trip:)
    @trip = trip
  end

  def view_template
    Sheet(title: "Groceries for #{@trip.title}") do
      if @trip.meals.none?
        Text { "Nothing is planned this week." }
      else
        Stack do
          meals
          ShoppingReview(trip: @trip)
        end
      end
    end
  end

  private
    # Ticking a meal redraws the ingredients below (a GET into the ingredients frame).
    def meals
      ActionForm(action: new_grocery_list_meal_plan_path, method: :get,
                 data: { turbo_frame: "shop-ingredients", controller: "autosubmit", action: "change->autosubmit#queue" }) do
        Stack(gap: :sm) do
          Heading(level: 4) { "Meals" }
          input(type: :hidden, name: "date", value: @trip.week_start)
          input(type: :hidden, name: "meal_ids[]", value: "")
          @trip.meals.each do |meal|
            Row(gap: :sm, class: "flex-nowrap") do
              Checkbox(id: "meal_#{meal.id}", name: "meal_ids[]", value: meal.id, checked: @trip.selected?(meal))
              FormFieldLabel(for: "meal_#{meal.id}", class: "min-w-0 flex-1 cursor-pointer truncate", title: meal_label(meal)) { meal_label(meal) }
            end
          end
        end
      end
    end

    def meal_label(meal)
      "#{meal.date.strftime('%a')} · #{meal.recipe.name}#{" ×#{meal.multiplier}" if meal.multiplier > 1}"
    end
end
