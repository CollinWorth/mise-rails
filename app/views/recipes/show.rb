class Views::Recipes::Show < Views::Base
  def initialize(recipe:, scale: Scale.default)
    @recipe = recipe
    @scale = scale
  end

  def view_template
    PageHeader(title: @recipe.name) { actions }
    Row(gap: :sm) do
      Link(href: user_path(@recipe.user)) { "by #{@recipe.user.name}" }
      Badge(variant: :outline) { "Prep #{@recipe.prep_time} min" } if @recipe.prep_time
      Badge(variant: :outline) { "Cook #{@recipe.cook_time} min" } if @recipe.cook_time
      Badge(variant: :outline) { "Serves #{Quantity.format(@recipe.servings * @scale.factor)}" } if @recipe.servings
      Badge(variant: :outline) { @recipe.cuisine } if @recipe.cuisine.present?
      Badge(variant: :outline) { @recipe.category } if @recipe.category.present?
      Badge(variant: :outline) { "★ #{@recipe.average_rating}" } if @recipe.average_rating
    end
    Link(href: @recipe.source_url, target: "_blank", rel: "noopener noreferrer") { "Source: #{@recipe.source_host}" } if @recipe.source_host
    Text { "Saved from #{@recipe.original.user.name}'s recipe" } if @recipe.original && @recipe.original.public?
    RecipeImage(recipe: @recipe, size: :full)
    ingredients
    steps
    reactions
    versions
    comments
  end

  private
    def owner? = Current.user == @recipe.user

    def actions
      Link(href: recipe_cook_path(@recipe, scale: @scale.to_param), variant: :primary) { "Cook" }
      if Current.user
        SheetLink(href: new_planned_meal_path(recipe_id: @recipe.id), variant: :outline) { "Add to plan" }
        ButtonTo(action: recipe_grocery_items_path(@recipe), params: { scale: @scale.key }, size: :md) { "Add to grocery list" }
      end
      if @recipe.public?
        Button(type: :button, variant: :outline, size: :md, hidden: true,
               data: { controller: "share", action: "share#share", share_title_value: @recipe.name, share_url_value: recipe_url(@recipe) }) { "Share" }
      end
      if owner?
        Link(href: edit_recipe_path(@recipe), variant: :outline) { "Edit" }
        ButtonTo(action: recipe_path(@recipe), method: :delete, variant: :destructive, data: { turbo_confirm: "Delete #{@recipe.name}? This can't be undone." }) { "Delete" }
      elsif Current.user
        ButtonTo(action: recipe_copy_path(@recipe)) { "Save to my recipes" }
      end
    end

    def ingredients
      Card do
        CardHeader do
          Row(justify: :between) do
            CardTitle { "Ingredients" }
            scale_links
          end
        end
        CardContent do
          Stack(gap: :sm) do
            @recipe.ingredients.each do |ingredient|
              if ingredient.section?
                Heading(level: 4) { ingredient.name }
              else
                Text { ingredient.to_line(@scale.factor) }
              end
            end
          end
        end
      end
    end

    def scale_links
      Row(gap: :sm) do
        Scale::ALL.each do |scale|
          Link(href: recipe_path(@recipe, scale: scale.to_param), variant: scale == @scale ? :secondary : :ghost, size: :sm, data: { turbo_action: "replace" }) { scale.label }
        end
      end
    end

    def steps
      Card do
        CardHeader { CardTitle { "Instructions" } }
        CardContent do
          Stack(gap: :sm) { @recipe.steps.each_with_index { |step, index| Text { "#{index + 1}. #{step}" } } }
        end
      end
    end

    def reactions
      return unless Current.user

      Row do
        if @recipe.liked_by?(Current.user)
          ButtonTo(action: recipe_like_path(@recipe), method: :delete, variant: :primary) { "♥ #{@recipe.likes.count}" }
        else
          ButtonTo(action: recipe_like_path(@recipe)) { "♡ #{@recipe.likes.count}" }
        end
        RatingControl(recipe: @recipe, user_rating: @recipe.rating_by(Current.user))
      end
    end

    def versions
      return if @recipe.versions.none?

      Heading(level: 3) { "Versions by other cooks" }
      RecipeGrid(recipes: @recipe.versions.includes(:user), show_author: true)
    end

    def comments
      Heading(level: 3) { "Comments (#{@recipe.comments.size})" }
      @recipe.comments.includes(:user).each do |comment|
        Card do
          CardHeader { CardDescription { comment.user.name } }
          CardContent do
            Row(justify: :between) do
              Text { comment.body }
              ButtonTo(action: recipe_comment_path(@recipe, comment), method: :delete, variant: :ghost) { "Delete" } if comment.user == Current.user
            end
          end
        end
      end
      return unless Current.user

      ActionForm(action: recipe_comments_path(@recipe)) do
        Stack(gap: :sm) do
          TextAreaField(label: "Add a comment", name: "comment[body]", rows: 3)
          Button(type: :submit) { "Post" }
        end
      end
    end
end
