class Views::PlannedMeals::Index < Views::Base
  def initialize(week_start:, meals:, recipes:)
    @week_start = week_start
    @meals = meals
    @recipes = recipes
  end

  def view_template
    PageHeader(title: "Week of #{@week_start.strftime('%b %-d')}") do
      Link(href: planned_meals_path(date: @week_start - 7), variant: :outline) { "← Previous" }
      Link(href: planned_meals_path(date: Date.current), variant: :outline) { "Today" }
      Link(href: planned_meals_path(date: @week_start + 7), variant: :outline) { "Next →" }
      ButtonTo(action: grocery_list_meal_plan_path, params: { date: @week_start }, variant: :primary) { "Add week to grocery list" }
    end
    Grid(columns: 4) { (0..6).each { |offset| day(@week_start + offset) } }
  end

  private
    def day(date)
      Card do
        CardHeader { CardTitle { date.strftime("%A, %b %-d") } }
        CardContent do
          Stack(gap: :sm) do
            @meals.fetch(date, []).each do |meal|
              Row(gap: :sm, justify: :between) do
                Link(href: recipe_path(meal.recipe)) { meal.multiplier > 1 ? "#{meal.recipe.name} ×#{meal.multiplier}" : meal.recipe.name }
                ButtonTo(action: planned_meal_path(meal), method: :delete, variant: :ghost) { "Remove" }
              end
            end
            add_form(date) if @recipes.any?
          end
        end
      end
    end

    def add_form(date)
      ActionForm(action: planned_meals_path) do
        Stack(gap: :sm) do
          input(type: :hidden, name: "planned_meal[date]", value: date)
          SelectField(label: "Add a recipe", name: "planned_meal[recipe_id]", options: @recipes.map { |recipe| [ recipe.name, recipe.id ] }, id: "recipe_#{date}")
          Field(label: "Times", name: "planned_meal[multiplier]", type: :number, value: 1, min: 1, id: "multiplier_#{date}")
          Button(type: :submit, size: :sm) { "Add" }
        end
      end
    end
end
