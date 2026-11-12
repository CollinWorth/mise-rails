class Components::RecipeImage < Components::Base
  include Phlex::Rails::Helpers::URLFor

  def initialize(recipe:, size: :card)
    @recipe = recipe
    @size = size
  end

  def view_template
    return unless @recipe.image.attached? && @recipe.image.blob.persisted? && @recipe.image.variable?

    img(src: url_for(@recipe.image.variant(@size == :card ? :card : :large)), alt: @recipe.name, loading: "lazy",
        class: [ "w-full rounded-md object-cover", @size == :card ? "h-40" : "max-h-96" ])
  end
end
