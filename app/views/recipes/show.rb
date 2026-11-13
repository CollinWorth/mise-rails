class Views::Recipes::Show < Views::Base
  def initialize(recipe:, scale: Scale.default)
    @recipe = recipe
    @scale = scale
  end

  def view_template
    Grid(columns: :hero) do
      RecipeImage(recipe: @recipe, size: :hero, eager: true, class: "rounded-xl")
      Stack(gap: :lg) do
        title_block
        Row(gap: :sm) { actions }
        reactions
      end
    end
    Grid(columns: :aside, data: { controller: "checklist", checklist_key_value: "recipe-#{@recipe.id}", action: "turbo:render@document->checklist#restore" }) do
      ingredients
      Stack do
        Row(justify: :between) do
          Heading(level: 2) { "Instructions" }
          Button(type: :button, variant: :ghost, size: :sm, class: "text-muted-foreground", data: { action: "checklist#clear" }) { "Clear ticks" }
        end
        Steps(steps: @recipe.steps)
      end
    end
    versions
    comments
  end

  private
    def owner? = Current.user == @recipe.user

    def title_block
      Stack(gap: :sm) do
        Row(gap: :sm) do
          Avatar(name: @recipe.user.name, size: "size-6 text-xs")
          TextLink(href: user_path(@recipe.user), class: "text-sm font-medium text-foreground") { @recipe.user.name }
          Text(size: "2", class: "text-muted-foreground") { "Saved from #{@recipe.original.user.name}'s recipe" } if @recipe.original && @recipe.original.public?
        end
        Heading(level: 1) { @recipe.name }
        facts
        TextLink(href: @recipe.source_url, target: "_blank", rel: "noopener noreferrer", class: "text-sm") { "Source: #{@recipe.source_host}" } if @recipe.source_host
      end
    end

    def facts
      Row(gap: :sm) do
        # times and servings in the theme's secondary color; cuisine, category and rating in its tertiary one
        Tag { "Prep #{@recipe.prep_time} min" } if @recipe.prep_time
        Tag { "Cook #{@recipe.cook_time} min" } if @recipe.cook_time
        Tag { "Serves #{Quantity.format(@recipe.servings * @scale.factor)}" } if @recipe.servings
        Tag(tone: :tertiary) { @recipe.cuisine } if @recipe.cuisine.present?
        Tag(tone: :tertiary) { @recipe.category } if @recipe.category.present?
        Tag(tone: :tertiary) { "★ #{@recipe.average_rating}" } if @recipe.average_rating
      end
    end

    def actions
      if Current.user
        SheetLink(href: new_planned_meal_path(recipe_id: @recipe.id), variant: :primary, size: :lg) { "Add to plan" }
        ButtonTo(action: recipe_grocery_items_path(@recipe), params: { scale: @scale.key }, size: :lg) { "Add to grocery list" }
      end
      more_menu if Current.user || @recipe.public?
    end

    def more_menu
      Menu(label: "More actions", align: :start, trigger: -> { span(class: "flex size-10 items-center justify-center rounded-full border") { Icon(:ellipsis) } }) do
        if @recipe.public?
          MenuItem(icon: :share, hidden: true, data: { controller: "share", action: "share#share", share_title_value: @recipe.name, share_url_value: recipe_url(@recipe) }) { "Share" }
        end
        if owner?
          MenuItem(href: edit_recipe_path(@recipe), icon: :pencil) { "Edit" }
          MenuItem(action: recipe_path(@recipe), method: :delete, icon: :trash, data: { turbo_confirm: "Delete #{@recipe.name}? This can't be undone." }) { "Delete" }
        elsif Current.user
          MenuItem(action: recipe_copy_path(@recipe), icon: :bookmark) { "Save to my recipes" }
        end
      end
    end

    def ingredients
      Card(class: "lg:sticky lg:top-20") do
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
                Heading(level: 4, class: "mt-2 text-sm uppercase tracking-wide text-brand-3") { ingredient.name }
              else
                ChecklistItem(value: "i#{ingredient.id}") { ingredient.to_line(@scale.factor) }
              end
            end
          end
        end
      end
    end

    def scale_links
      Segmented do |scales|
        Scale::ALL.each { |scale| scales.option(scale.label, recipe_path(@recipe, scale: scale.to_param), active: scale == @scale, data: { turbo_action: "replace" }) }
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
      Stack(class: "max-w-2xl") do
        Heading(level: 3) { "Comments (#{@recipe.comments.size})" }
        @recipe.comments.includes(:user).each { |comment| comment_row(comment) }
        comment_form if Current.user
      end
    end

    def comment_row(comment)
      Row(gap: :sm, class: "flex-nowrap items-start") do
        Avatar(name: comment.user.name)
        Stack(gap: :sm, class: "min-w-0 flex-1") do
          Row(gap: :sm, justify: :between) do
            Row(gap: :sm) do
              Text(as: "span", size: "2", weight: "medium") { comment.user.name }
              Text(as: "span", size: "1", class: "text-muted-foreground") { "#{view_context.time_ago_in_words(comment.created_at)} ago" }
            end
            ButtonTo(action: recipe_comment_path(@recipe, comment), method: :delete, variant: :ghost, button_class: "h-auto px-1 py-0 text-xs text-muted-foreground") { "Delete" } if comment.user == Current.user
          end
          Text { comment.body }
        end
      end
    end

    def comment_form
      ActionForm(action: recipe_comments_path(@recipe)) do
        Stack(gap: :sm) do
          TextAreaField(label: "Add a comment", name: "comment[body]", rows: 3)
          Button(type: :submit, class: "self-start") { "Post" }
        end
      end
    end
end
