# A slowly scrolling band of public recipes (pauses under the pointer). The list is repeated until it fills the screen,
# and the whole track is doubled so it loops without a jump.
class Components::Landing::Strip < Components::Base
  def initialize(recipes:)
    @recipes = recipes
  end

  def view_template
    items = @recipes * (8.0 / @recipes.size).ceil
    section(class: "py-12 lg:py-16") do
      Stack(gap: :sm, class: "mx-auto mb-8 max-w-6xl px-4", data: { controller: "reveal" }) do
        Heading(level: 2, size: "7", class: "sm:text-3xl") { "Fresh from the community" }
        Text(weight: "muted") { "Public recipes from cooks on Mise. Tap one to see how it's written up." }
      end
      div(class: "marquee overflow-hidden [mask-image:linear-gradient(to_right,transparent,black_8%,black_92%,transparent)]") do
        div(class: "marquee-track", style: "--duration: #{items.size * 7}s") do
          (items + items).each_with_index { |recipe, index| tile(recipe, hidden: index >= items.size) }
        end
      end
    end
  end

  private
    def tile(recipe, hidden:)
      a(href: recipe_path(recipe), class: "block w-60 shrink-0", tabindex: (-1 if hidden), aria_hidden: (hidden ? "true" : nil)) do
        Card(class: "overflow-hidden rounded-2xl shadow-sm transition hover:-translate-y-0.5 hover:shadow-md") do
          RecipeImage(recipe:)
          Stack(gap: :sm, class: "gap-0 p-3") do
            Text(as: "span", size: "2", weight: "semibold", class: "truncate") { recipe.name }
            Text(as: "span", size: "1", weight: "muted", class: "truncate") { "by #{recipe.user.name}" }
          end
        end
      end
    end
end
