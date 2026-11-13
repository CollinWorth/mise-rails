# A real public recipe, pinned to the door as a photo with a magnet on top. It opens the recipe.
class Components::Fridge::Polaroid < Components::Base
  include Components::Fridge
  include Phlex::Rails::Helpers::URLFor

  def initialize(recipe:)
    @recipe = recipe
  end

  def view_template
    a(href: recipe_path(@recipe), aria: { label: "Open #{@recipe.name}" },
      class: "magnet-in absolute left-(--x) top-(--y) z-[1] block w-[31cqw] rotate-3 bg-background p-[1.8cqw] pb-[1cqw] #{PHOTO_SHADOW} transition-transform hover:rotate-1 hover:scale-105 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring md:left-(--mx) md:top-(--my) md:w-[17cqw] md:p-[1cqw] md:pb-[0.6cqw]",
      style: "--x: 63%; --y: 3.5%; --mx: 50%; --my: 6%; --d: 0.6s") do
      span(class: "absolute left-1/2 top-[-2cqw] z-[1] size-[4.6cqw] -translate-x-1/2 rounded-full bg-primary shadow-md md:top-[-0.9cqw] md:size-[2cqw]", aria_hidden: "true")
      span(class: "block aspect-square overflow-hidden") { RecipeImage(recipe: @recipe, class: "h-full") }
      span(class: "block truncate pt-[1cqw] text-center #{HAND} text-[4cqw] font-bold leading-tight md:text-[1.5cqw]") { @recipe.name }
    end
  end
end
