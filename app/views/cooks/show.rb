# Cook mode: just the steps, one at a time, with the ingredients alongside.
class Views::Cooks::Show < Views::Base
  def initialize(recipe:, scale: Scale.default)
    @recipe = recipe
    @scale = scale
  end

  def view_template
    Stack(data: { controller: "wake-lock" }) do
      PageHeader(title: @recipe.name) { Link(href: recipe_path(@recipe), variant: :outline) { "Done" } }
      Grid(columns: 2) do
        ingredients
        steps
      end
    end
  end

  private
    def ingredients
      Card do
        CardHeader { CardTitle { "Ingredients" } }
        CardContent do
          Stack(gap: :sm) do
            @recipe.ingredients.reject(&:section?).each do |ingredient|
              Row(gap: :sm) do
                Checkbox(id: "ingredient_#{ingredient.id}")
                FormFieldLabel(for: "ingredient_#{ingredient.id}") { ingredient.to_line(@scale.factor) }
              end
            end
          end
        end
      end
    end

    def steps
      Stack do
        @recipe.steps.each_with_index do |step, index|
          Card(data: { controller: "done", action: "click->done#toggle" }, role: "button", class: "cursor-pointer transition-opacity") do
            CardHeader { CardTitle { "Step #{index + 1}" } }
            CardContent { Text { step } }
          end
        end
      end
    end
end
