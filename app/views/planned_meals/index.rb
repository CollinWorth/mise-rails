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
      SheetLink(href: new_grocery_list_meal_plan_path(date: @week_start), variant: :primary) { "Shop for this week" }
    end
    Grid(columns: 7) { (0..6).each { |offset| day(@week_start + offset) } }
  end

  private
    def day(date)
      today = date == Date.current
      Card(class: today ? "ring-2 ring-primary" : "", data: { controller: ("scroll-into-view" if today) }) do
        CardHeader do
          Row(justify: :between) do
            Stack(gap: :sm) do
              CardTitle { date.strftime("%A") }
              CardDescription { date.strftime("%b %-d") }
            end
            Badge { "Today" } if today
          end
        end
        CardContent do
          Stack(gap: :sm) do
            @meals.fetch(date, []).each do |meal|
              Stack(gap: :sm) do
                TextLink(href: recipe_path(meal.recipe)) { meal.multiplier > 1 ? "#{meal.recipe.name} ×#{meal.multiplier}" : meal.recipe.name }
                ButtonTo(action: planned_meal_path(meal), method: :delete, variant: :ghost, button_class: "h-auto px-0 py-0 text-xs text-muted-foreground") { "Remove" }
              end
            end
            SheetLink(href: new_planned_meal_path(date:), variant: :outline, size: :sm) { "+ Add" }
          end
        end
      end
    end
end
