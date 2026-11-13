# A recipe thumbnail: the whole card opens the recipe (a stretched link), and the + button plans it without opening.
class Components::RecipeCard < Components::Base
  def initialize(recipe:, show_author: false, eager: false)
    @recipe = recipe
    @eager = eager
    @show_author = show_author
  end

  def view_template
    Card(class: "group relative overflow-hidden transition duration-200 hover:-translate-y-0.5 hover:shadow-md") do
      div(class: "relative overflow-hidden") do
        RecipeImage(recipe: @recipe, eager: @eager, class: "transition duration-300 group-hover:scale-105")
        plan_button if Current.user
      end
      CardHeader(class: "gap-1 p-4 pb-2") do
        CardTitle(class: "text-base leading-snug") { TextLink(href: recipe_path(@recipe), class: "font-semibold text-foreground after:absolute after:inset-0") { @recipe.name } }
        CardDescription { byline } if byline.present?
      end
      CardContent(class: "p-4 pt-0") do
        Row(gap: :sm, class: "text-xs text-muted-foreground") do
          span(class: "inline-flex items-center gap-1") { Icon(:clock, class: "size-3.5"); plain "#{@recipe.total_time} min" } if @recipe.total_time.positive?
          span { @recipe.cuisine } if @recipe.cuisine.present?
          span(class: "font-medium text-foreground") { "★ #{@recipe.average_rating}" } if @recipe.average_rating
          Badge(variant: :outline) { "Private" } unless @recipe.public?
        end
      end
    end
  end

  private
    def plan_button
      SheetLink(href: new_planned_meal_path(recipe_id: @recipe.id), variant: :secondary, size: :sm, aria: { label: "Add #{@recipe.name} to plan" },
                class: "absolute right-2 top-2 z-10 size-9 rounded-full bg-background/90 p-0 shadow backdrop-blur hover:bg-background") { Icon(:plus) }
    end

    def byline
      @byline ||= [ (@recipe.user.name if @show_author), ("Saved from #{@recipe.original.user.name}" if @recipe.original) ].compact.join(" · ")
    end
end
