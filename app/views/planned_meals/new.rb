# The add-a-meal sheet. With a date it lists your recipes to pick from; with a recipe it lists days to pick from.
class Views::PlannedMeals::New < Views::Base
  DAYS_AHEAD = 14

  def initialize(date: nil, recipe: nil, recipes: [], query: "")
    @date = date
    @recipe = recipe
    @recipes = recipes
    @query = query
  end

  def view_template
    Sheet(title: @recipe ? "Add #{@recipe.name} to…" : "Add to #{@date.strftime('%A, %b %-d')}") do
      @recipe ? days : recipe_search
    end
  end

  private
    def recipe_search
      Stack do
        ActionForm(action: new_planned_meal_path, method: :get, data: { turbo_frame: "meal-results", controller: "autosubmit" }) do
          input(type: :hidden, name: "date", value: @date)
          Input(type: :search, name: :q, value: @query, placeholder: "Search your recipes", autofocus: true, data: { action: "input->autosubmit#queue" })
        end
        turbo_frame(id: "meal-results") { recipes }
      end
    end

    def recipes
      return Text { @query.present? ? "No recipes match “#{@query}”." : "You have no recipes yet." } if @recipes.none?

      ActionForm(action: planned_meals_path, top: true) do
        Stack(gap: :sm) do
          input(type: :hidden, name: "planned_meal[date]", value: @date)
          @recipes.each { |recipe| choice(recipe.name, name: "planned_meal[recipe_id]", value: recipe.id) }
        end
      end
    end

    def days
      ActionForm(action: planned_meals_path, top: true) do
        Stack(gap: :sm) do
          input(type: :hidden, name: "planned_meal[recipe_id]", value: @recipe.id)
          DAYS_AHEAD.times { |offset| choice(day_label(Date.current + offset), name: "planned_meal[date]", value: Date.current + offset) }
        end
      end
    end

    def choice(label, **attrs)
      Button(type: :submit, variant: :outline, class: "h-auto min-h-12 w-full justify-start whitespace-normal break-words py-3 text-left", **attrs) { label }
    end

    def day_label(date)
      case date
      when Date.current then "Today · #{date.strftime('%b %-d')}"
      when Date.current + 1 then "Tomorrow · #{date.strftime('%b %-d')}"
      else date.strftime("%A, %b %-d")
      end
    end
end
