# The front door for people who aren't signed in: a fridge door to play with (drag the words, tick the list, roll a dinner),
# then the ways in. The previous, longer page is still at /classic. Every color comes from the active theme.
class Views::Landing::Show < Views::Base
  # `recipes` are public recipes with photos (for the photo magnet); `dinners` are names of public recipes for the dinner note.
  def initialize(recipes:, dinners:)
    @recipes = recipes
    @dinners = dinners
  end

  def bleed? = true

  def view_template
    Stack(gap: :lg, class: "mx-auto w-full max-w-5xl px-4 py-6 md:py-10") do
      Heading(level: 1, class: "sr-only") { "Mise: dinner, decided. Save recipes, plan the week, and shop from one list." }
      Fridge::Door(recipes: @recipes, dinners: @dinners)
      ways_in
      Fridge::ColorMagnets()
    end
    Landing::Footer()
  end

  private
    def ways_in
      Stack(gap: :md, class: "items-center text-center") do
        Text(class: "max-w-md text-balance text-muted-foreground") { "Save recipes from anywhere, plan the week, and shop from one list that already knows your pantry." }
        Row(gap: :sm, justify: :center) do
          Link(href: new_registration_path, variant: :primary, size: :xl, class: "rounded-full shadow-lg shadow-primary/30") { "Get started" }
          Link(href: new_session_path, variant: :outline, size: :xl, class: "rounded-full") { "Sign in" }
        end
        TextLink(href: discover_path, class: "text-sm text-muted-foreground") { "or just browse recipes" }
      end
    end
end
