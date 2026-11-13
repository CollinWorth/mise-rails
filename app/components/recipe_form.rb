class Components::RecipeForm < Components::Base
  def initialize(recipe:)
    @recipe = recipe
  end

  def view_template
    ActionForm(action: @recipe.persisted? ? recipe_path(@recipe) : recipes_path, method: @recipe.persisted? ? :patch : :post, multipart: true, class: "max-w-2xl") do
      Stack do
        ErrorMessages(record: @recipe)
        field(:name, "Name", required: true)
        Row do
          field(:cuisine, "Cuisine")
          field(:category, "Category")
          field(:tags, "Tags")
        end
        Row do
          field(:prep_time, "Prep (min)", type: :number, inputmode: "numeric")
          field(:cook_time, "Cook (min)", type: :number, inputmode: "numeric")
          field(:servings, "Servings", type: :number, inputmode: "numeric")
        end
        PhotoField(recipe: @recipe)
        ingredients
        field(:source_url, "Source link (optional)", type: :url, inputmode: "url", autocapitalize: "none", autocorrect: "off")
        TextAreaField(label: "Instructions (one step per line)", name: "recipe[instructions]", value: @recipe.instructions, rows: 10)
        Row(gap: :sm) do
          input(type: :hidden, name: "recipe[public]", value: "0")
          Checkbox(id: "recipe_public", name: "recipe[public]", value: "1", checked: @recipe.public?)
          FormFieldLabel(for: "recipe_public") { "Share publicly" }
        end
        Row do
          Button(type: :submit) { "Save recipe" }
          Link(href: @recipe.persisted? ? recipe_path(@recipe) : recipes_path, variant: :ghost) { "Cancel" }
        end
      end
    end
  end

  private
    def field(attribute, label, type: :text, **attrs)
      Field(label:, name: "recipe[#{attribute}]", type:, value: @recipe.public_send(attribute), errors: @recipe.errors[attribute], **attrs)
    end

    def ingredients
      rows = @recipe.ingredients.to_a
      rows << @recipe.ingredients.build if rows.empty?

      Stack(gap: :sm, data: { controller: "nested-form" }) do
        Heading(level: 3) { "Ingredients" }
        div(data: { nested_form_target: "list" }) { rows.each_with_index { |ingredient, index| IngredientFields(ingredient:, index:) } }
        template(data: { nested_form_target: "template" }) { IngredientFields(ingredient: Ingredient.new, index: "NEW_RECORD") }
        template(data: { nested_form_target: "sectionTemplate" }) { IngredientFields(ingredient: Ingredient.new(section: true), index: "NEW_RECORD") }
        Row(gap: :sm) do
          Button(type: :button, variant: :secondary, size: :sm, data: { action: "nested-form#add" }) { "Add ingredient" }
          Button(type: :button, variant: :ghost, size: :sm, data: { action: "nested-form#addSection" }) { "Add section" }
        end
      end
    end
end
