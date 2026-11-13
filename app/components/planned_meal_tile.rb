# A planned meal: the recipe's photo and name (a link to the recipe), how many times it's cooked, and a way to take it off the day.
class Components::PlannedMealTile < Components::Base
  def initialize(meal:)
    @meal = meal
  end

  def view_template
    recipe = @meal.recipe
    div(class: "group relative flex items-center gap-3 rounded-lg lg:flex-col lg:items-stretch lg:gap-2") do
      div(class: "size-14 shrink-0 overflow-hidden rounded-lg lg:size-auto") { RecipeImage(recipe:, class: "h-full") }
      div(class: "min-w-0 flex-1 pr-8 lg:pr-0") do
        TextLink(href: recipe_path(recipe), class: "line-clamp-2 text-sm font-medium after:absolute after:inset-0") { recipe.name }
        details
      end
      ButtonTo(action: planned_meal_path(@meal), method: :delete, variant: :ghost, size: :sm, button_class: "absolute right-0 top-0 z-10 size-8 p-0 text-muted-foreground lg:bg-card/80", button_attrs: { aria: { label: "Remove #{recipe.name} from #{@meal.date.strftime('%A')}" } }) { Icon(:x, class: "size-4") }
    end
  end

  private
    def details
      return unless @meal.multiplier > 1 || @meal.recipe.total_time.positive?

      div(class: "mt-0.5 flex flex-wrap items-center gap-x-2 text-xs text-muted-foreground") do
        span(class: "font-medium text-brand-2") { "×#{@meal.multiplier}" } if @meal.multiplier > 1
        span { "#{@meal.recipe.total_time} min" } if @meal.recipe.total_time.positive?
      end
    end
end
