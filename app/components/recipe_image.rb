# A recipe's photo, or a colored tile with its initial when it has none (the tile keeps cards the same height).
class Components::RecipeImage < Components::Base
  include Phlex::Rails::Helpers::URLFor

  TILES = [
    "from-orange-400/30 to-amber-300/20 text-orange-600 dark:text-orange-300",
    "from-rose-400/30 to-orange-300/20 text-rose-600 dark:text-rose-300",
    "from-lime-400/30 to-emerald-300/20 text-lime-700 dark:text-lime-300",
    "from-sky-400/30 to-indigo-300/20 text-sky-600 dark:text-sky-300",
    "from-amber-400/30 to-yellow-300/20 text-amber-700 dark:text-amber-300",
    "from-fuchsia-400/30 to-pink-300/20 text-fuchsia-600 dark:text-fuchsia-300"
  ].freeze

  # :card is a 16:9 thumbnail; :hero fills the recipe page's photo column. Pixel sizes match the variants in Recipe.
  SHAPES = { card: "aspect-video", hero: "aspect-[4/3]" }.freeze
  PIXELS = { card: [ 640, 360 ], hero: [ 900, 675 ] }.freeze

  # `eager` is for photos already on screen when the page opens; the rest load as they scroll into view.
  def initialize(recipe:, size: :card, eager: false, **attrs)
    @recipe = recipe
    @size = size
    @eager = eager
    @attrs = attrs
  end

  def view_template
    if photo?
      width, height = PIXELS.fetch(@size)
      img(src: url_for(@recipe.image.variant(@size)), alt: @recipe.name, width:, height:, decoding: "async", loading: (@eager ? "eager" : "lazy"), fetchpriority: (@eager ? "high" : "auto"),
          class: [ "w-full object-cover", SHAPES.fetch(@size), @attrs[:class] ])
    else
      div(class: [ "flex w-full items-center justify-center bg-gradient-to-br", SHAPES.fetch(@size), TILES[@recipe.name.to_s.sum % TILES.size], @attrs[:class] ], aria_hidden: "true") do
        span(class: "text-5xl font-bold") { @recipe.name.to_s.strip[0].to_s.upcase }
      end
    end
  end

  private
    def photo? = @recipe.image.attached? && @recipe.image.blob.persisted? && @recipe.image.variable?
end
