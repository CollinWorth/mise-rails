# The landing page's fridge door: a themed surface covered in things to play with. The headline is magnet words that drag
# (magnets_controller.js), next to a grocery note that ticks off, a note that picks tonight's dinner, and a photo of a real
# recipe. Positions are percentages of the door, with a second set for wide screens, and sizes follow the door's width, so it
# scales as one piece. Every color comes from the active theme.
class Components::Fridge::Door < Components::Base
  include Components::Fridge
  # [text, x, y, wide x, wide y, tilt, style]; x and y are % of the door's width and height.
  HEADLINE = [
    [ "dinner,", 6, 4, 4, 8, -3, :big ],
    [ "decided.", 9, 17, 8, 28, 2, :hero ]
  ].freeze
  WORDS = [
    [ "tonight", 5, 36.5, 4, 60, -2, :plain ], [ "cozy", 31, 35.5, 17, 60.5, 3, :primary ], [ "crispy", 50, 37, 28, 59.5, -1, :plain ], [ "again", 73, 35.5, 42, 60.5, 2, :plain ],
    [ "pasta", 8, 43.5, 7, 68.5, 2, :secondary ], [ "for two", 30, 44.5, 19, 69, -2, :plain ], [ "plan", 55, 43.5, 34, 68, 1, :plain ], [ "shop", 73, 44.5, 45, 69, -3, :tertiary ],
    [ "cook", 5, 52, 4, 77, -2, :plain ], [ "hungry?", 25, 52.5, 15, 77.5, 2, :plain ], [ "slow", 53, 52, 30, 77, -1, :secondary ]
  ].freeze

  SAMPLE_DINNERS = [ "Lemony chicken thighs", "Tomato basil pasta", "Sheet-pan fajitas", "Mushroom risotto", "Crispy tofu bowls", "Shakshuka" ].freeze

  def initialize(recipes:, dinners:)
    @recipes = recipes
    @dinners = dinners
  end

  def view_template
    div(class: "mx-auto w-full max-w-5xl") do
      div(data: { controller: "magnets" },
          class: "@container relative aspect-[7/10.4] w-full touch-pan-y select-none overflow-hidden rounded-[2rem] border bg-gradient-to-b from-card via-card to-muted shadow-xl md:aspect-[16/9]") do
        trim
        (HEADLINE + WORDS).each_with_index { |word, index| Word(*word, delay: index) }
        hint
        photo
        GroceryNote()
        DinnerNote(names: @dinners.size >= 3 ? @dinners : SAMPLE_DINNERS)
      end
    end
  end

  private
    # The door's own details: a seam between freezer and fridge, a handle, and the light catching it.
    def trim
      div(class: "pointer-events-none absolute inset-0", aria_hidden: "true") do
        div(class: "absolute inset-0 bg-gradient-to-r from-foreground/[0.04] via-transparent to-foreground/[0.07]")
        div(class: "absolute inset-x-0 top-[33%] h-px bg-foreground/15 shadow-[0_1px_0_var(--background)] md:top-[52%]")
        div(class: "absolute right-[3cqw] top-[6%] h-[20%] w-[1.8cqw] rounded-full bg-gradient-to-r from-muted to-background shadow-md md:h-[30%] md:w-[0.9cqw]")
        div(class: "absolute right-[3cqw] top-[39%] h-[24%] w-[1.8cqw] rounded-full bg-gradient-to-r from-muted to-background shadow-md md:top-[58%] md:h-[30%] md:w-[0.9cqw]")
      end
    end

    # A scrawled arrow pointing at the headline; it goes away the first time a word moves.
    def hint
      div(data: { magnets_target: "hint" }, aria_hidden: "true",
          class: "pointer-events-none absolute left-(--x) top-(--y) z-10 -rotate-6 #{HAND} text-[4.4cqw] text-primary transition-opacity duration-500 md:left-(--mx) md:top-(--my) md:text-[1.8cqw]",
          style: "--x: 18%; --y: 28%; --mx: 12%; --my: 46%") do
        plain "↑ the words move!"
      end
    end

    def photo
      recipe = @recipes.find { |candidate| candidate.image.attached? }
      Polaroid(recipe:) if recipe
    end
end
