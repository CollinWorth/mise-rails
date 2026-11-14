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
          Input(type: :search, name: :q, value: @query, placeholder: "Search recipes, or type anything", maxlength: 80, autofocus: true, aria: { label: "Search recipes or type a note" }, data: { action: "input->autosubmit#queue" })
        end
        turbo_frame(id: "meal-results") { results }
      end
    end

    # What you typed can be a recipe search or the words themselves: "Leftovers", "Eating out", "Pizza at Sam's". The note choice
    # sits first, so typing something and tapping it is the whole job.
    def results
      ActionForm(action: planned_meals_path, top: true) do
        Stack(gap: :sm) do
          input(type: :hidden, name: "planned_meal[date]", value: @date)
          if @query.present?
            choice("Add “#{@query.first(80)}” as a note", icon: :pencil, variant: :secondary, name: "planned_meal[title]", value: @query.first(80))
          else
            Text(size: "2", class: "text-muted-foreground") { "Pick a recipe, or type something like “Leftovers” or “Eating out” to add it as a note." }
          end
          if @recipes.any?
            @recipes.each { |recipe| choice(recipe.name, name: "planned_meal[recipe_id]", value: recipe.id) }
          else
            Text { @query.present? ? "No recipes match “#{@query}”." : "You have no recipes yet." }
          end
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

    def choice(label, icon: nil, variant: :outline, **attrs)
      Button(type: :submit, variant:, class: "h-auto min-h-12 w-full justify-start gap-3 whitespace-normal break-words py-3 text-left", **attrs) do
        Icon(icon, class: "size-4 shrink-0") if icon
        plain label
      end
    end

    def day_label(date)
      case date
      when Date.current then "Today · #{date.strftime('%b %-d')}"
      when Date.current + 1 then "Tomorrow · #{date.strftime('%b %-d')}"
      else date.strftime("%A, %b %-d")
      end
    end
end
