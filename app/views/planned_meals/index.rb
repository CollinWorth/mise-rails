class Views::PlannedMeals::Index < Views::Base
  def initialize(week_start:, meals:)
    @week_start = week_start
    @meals = meals
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
            Link(href: new_planned_meal_path(date:), variant: :outline, size: :sm, data: { turbo_frame: "modal" }) { "+ Add" }
          end
        end
      end
    end
end
