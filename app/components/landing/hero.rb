# The first screen: the promise, two ways in, and a collage of recipes floating beside it, over drifting color.
class Components::Landing::Hero < Components::Base
  GRADIENT = "bg-gradient-to-r from-primary via-brand-2 to-brand-3 bg-clip-text text-transparent"

  def initialize(recipes:)
    @recipes = recipes
  end

  def view_template
    section(class: "relative overflow-hidden") do
      Glow(position: "-left-24 -top-28 size-96 bg-primary/25")
      Glow(position: "right-[-4rem] top-1/3 size-80 bg-brand-2/25", delay: "-5s")
      Glow(position: "bottom-[-5rem] left-1/3 size-72 bg-brand-3/25", delay: "-9s")

      div(class: "relative mx-auto grid max-w-6xl items-center gap-12 px-4 pb-20 pt-12 lg:grid-cols-[1.05fr_1fr] lg:pb-28 lg:pt-24") do
        copy
        Collage(recipes: @recipes)
      end
    end
  end

  private
    def copy
      Stack(gap: :lg, class: "items-start") do
        Badge(variant: :outline, class: "rise gap-2 bg-card/70 px-3 py-1 font-medium text-muted-foreground backdrop-blur") do
          Icon(:chef_hat, class: "size-4 text-primary")
          plain "Recipes · Meal plans · Groceries"
        end
        Heading(level: 1, size: "9", class: "rise text-5xl font-extrabold leading-[1.02] sm:text-6xl lg:text-7xl", style: "--delay: .08s") do
          plain "Dinner,"
          br
          span(class: GRADIENT) { "decided." }
        end
        Text(size: "4", weight: "muted", class: "rise max-w-lg", style: "--delay: .16s") { "Save recipes from anywhere, plan your week, and get a grocery list that already knows what's in your pantry." }
        Row(class: "rise", style: "--delay: .24s") do
          Link(href: new_registration_path, variant: :primary, size: :xl, class: "rounded-full shadow-lg shadow-primary/30") { "Get started" }
          Link(href: discover_path, variant: :outline, size: :xl, class: "rounded-full bg-card/70 backdrop-blur") { "Browse recipes" }
        end
        Text(size: "2", weight: "muted", class: "rise", style: "--delay: .3s") do
          plain "Already cooking with Mise? "
          TextLink(href: new_session_path, class: "font-medium text-foreground underline") { "Sign in" }
        end
      end
    end
end
