# A recipe's photo, or a colored tile with its initial when it has none (the tile keeps cards the same height).
class Components::RecipeImage < Components::Base
  include Phlex::Rails::Helpers::URLFor

  # Gradient and initial color, built from the active palette's three colors so the tiles always match it.
  TILES = [
    [ "bg-gradient-to-br from-primary/30 to-brand-2/25", "text-primary" ],
    [ "bg-gradient-to-tr from-brand-2/30 to-brand-3/25", "text-brand-2" ],
    [ "bg-gradient-to-bl from-brand-3/30 to-primary/20", "text-brand-3" ],
    [ "bg-gradient-to-tl from-primary/25 to-brand-3/30", "text-primary" ],
    [ "bg-gradient-to-r from-brand-2/25 to-primary/30", "text-brand-2" ],
    [ "bg-gradient-to-b from-brand-3/25 to-brand-2/30", "text-brand-3" ]
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
      gradient, letter = TILES[@recipe.name.to_s.sum % TILES.size]
      div(class: [ "flex w-full items-center justify-center", SHAPES.fetch(@size), gradient, @attrs[:class] ], aria_hidden: "true") do
        span(class: [ "text-5xl font-bold", letter ]) { @recipe.name.to_s.strip[0].to_s.upcase }
      end
    end
  end

  private
    def photo? = @recipe.image.attached? && @recipe.image.blob.persisted? && @recipe.image.variable?
end
