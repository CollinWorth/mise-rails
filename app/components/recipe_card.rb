class Components::RecipeCard < Components::Base
  def initialize(recipe:, show_author: false)
    @recipe = recipe
    @show_author = show_author
  end

  def view_template
    Card do
      CardHeader do
        RecipeImage(recipe: @recipe)
        CardTitle { Link(href: recipe_path(@recipe)) { @recipe.name } }
        CardDescription { byline } if byline.present?
      end
      CardContent do
        Row(gap: :sm) do
          Badge(variant: :outline) { "#{@recipe.total_time} min" } if @recipe.total_time.positive?
          Badge(variant: :outline) { @recipe.cuisine } if @recipe.cuisine.present?
          Badge(variant: :outline) { "★ #{@recipe.average_rating}" } if @recipe.average_rating
          Badge(variant: :secondary) { "Private" } unless @recipe.public?
        end
      end
    end
  end

  private
    def byline
      @byline ||= [ (@recipe.user.name if @show_author), ("Saved from #{@recipe.original.user.name}" if @recipe.original) ].compact.join(" · ")
    end
end
