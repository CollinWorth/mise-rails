# The front door for people who aren't signed in: a fridge to play with (drag the words, tick the list, roll a dinner), and one
# way in. The previous, longer page is still at /classic. Every color comes from the active theme.
class Views::Landing::Show < Views::Base
  # `recipes` are public recipes with photos (for the photo magnet); `dinners` are names of public recipes for the dinner note.
  def initialize(recipes:, dinners:)
    @recipes = recipes
    @dinners = dinners
  end

  def page_meta
    { title: "Dinner, decided", description: "Save recipes from anywhere, plan the week, and shop from one list that already knows your pantry.",
      image: absolute_url("/icon.png"), url: root_url }
  end

  def bleed? = true
  def quiet_nav? = true

  def view_template
    Heading(level: 1, class: "sr-only") { "Mise: dinner, decided. Save recipes, plan the week, and shop from one list." }
    Fridge::Stage(recipes: @recipes, dinners: @dinners) do
      Text(size: "6", weight: "semibold", class: "max-w-sm text-balance leading-snug") { "Save recipes from anywhere, plan the week, and shop from one list that already knows your pantry." }
      Link(href: new_registration_path, variant: :primary, size: :xl, class: "rounded-full shadow-lg shadow-primary/30") { "Get started" }
      Row(gap: :md, class: "text-sm") do
        TextLink(href: new_session_path, class: "text-muted-foreground") { "Already have an account? Sign in" }
        TextLink(href: discover_path, class: "text-muted-foreground") { "Browse recipes" }
      end
      Fridge::ColorMagnets()
    end
  end
end
