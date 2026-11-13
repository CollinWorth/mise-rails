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
        cooked_button
      end
    end
    versions
    Comments(recipe: @recipe)
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
        cooked_summary
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

    # What this cook has done with the recipe so far, e.g. "Cooked 3 times · last yesterday".
    def cooked_summary
      return unless latest_cooking

      Text(size: "2", class: "text-muted-foreground") { "Cooked #{cooked_count} #{'time'.pluralize(cooked_count)} · last #{day_words(latest_cooking.cooked_on)}" }
    end

    # The log button at the end of the steps; once pressed it turns into a confirmation with an undo.
    def cooked_button
      return unless Current.user

      if latest_cooking&.cooked_on == Date.current
        Row(justify: :between, class: "rounded-xl border bg-brand-2/10 p-3") do
          Row(gap: :sm) do
            Icon(:check, class: "size-5 text-brand-2")
            Text(weight: "medium") { "Cooked today" }
          end
          ButtonTo(action: recipe_cooking_path(@recipe), method: :delete, variant: :ghost) { "Undo" } if latest_cooking.undoable?
        end
      else
        ButtonTo(action: recipe_cooking_path(@recipe), variant: :primary, size: :lg) { "I cooked this" }
      end
    end

    def latest_cooking
      return unless Current.user

      @latest_cooking = Current.user.cookings.where(recipe: @recipe).newest.first unless defined?(@latest_cooking)
      @latest_cooking
    end

    def cooked_count = Current.user.cookings.where(recipe: @recipe).count

    def day_words(date)
      case date
      when Date.current then "today"
      when Date.current - 1 then "yesterday"
      else "on #{date.strftime('%b %-d')}"
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
end
