# The landing page's fridge: a tall two-door fridge (freezer on top) with handles, a seal between the doors, a nameplate and
# feet, covered in things to play with. The headline is magnet words that drag (magnets_controller.js), next to a grocery note
# that ticks off, a note that picks tonight's dinner, and a photo of a real recipe. Everything is placed in units of the door's
# width (cqw) so it scales as one piece, and every color comes from the active theme.
class Components::Fridge::Door < Components::Base
  include Components::Fridge

  # The door is 7 wide by 11.6 tall: 100cqw wide, about 166cqw tall. The seal between the doors is at 61cqw.
  # [text, x as % of the width, y in cqw, tilt, style]
  WORDS = [
    [ "dinner,", 6, 5, -3, :big ], [ "decided.", 9, 22, 2, :hero ],
    [ "tonight", 5, 50, -2, :plain ], [ "cozy", 31, 49, 3, :primary ], [ "crispy", 50, 50.5, -1, :plain ], [ "again", 73, 49, 2, :plain ],
    [ "pasta", 8, 68, 2, :secondary ], [ "for two", 30, 69, -2, :plain ], [ "plan", 55, 68, 1, :plain ], [ "shop", 72, 69, -3, :tertiary ],
    [ "cook", 5, 79, -2, :plain ], [ "hungry?", 25, 79.5, 2, :plain ], [ "slow", 53, 79, -1, :secondary ]
  ].freeze
  SAMPLE_DINNERS = [ "Lemony chicken thighs", "Tomato basil pasta", "Sheet-pan fajitas", "Mushroom risotto", "Crispy tofu bowls", "Shakshuka" ].freeze

  def initialize(recipes:, dinners:)
    @recipes = recipes
    @dinners = dinners
  end

  def view_template
    div(class: "relative mx-auto w-full max-w-sm pb-3 md:max-w-md") do
      div(data: { controller: "magnets" }, class: "@container relative aspect-[7/11.6] w-full touch-pan-y select-none overflow-hidden rounded-[1.6rem] border-2 #{BODY}") do
        trim
        WORDS.each_with_index { |word, index| Word(*word, delay: index) }
        hint
        photo
        GroceryNote()
        DinnerNote(names: @dinners.size >= 3 ? @dinners : SAMPLE_DINNERS)
      end
      feet
    end
  end

  private
    # What makes it a fridge: brushed enamel, a dark seal between freezer and fridge door, chrome handles at the edge of each
    # door, a nameplate, and a light streak down the front.
    def trim
      div(class: "pointer-events-none absolute inset-0", aria_hidden: "true") do
        div(class: "absolute inset-0 #{BRUSHED}")
        div(class: "absolute inset-y-0 left-[8%] w-[22%] -skew-x-6 bg-gradient-to-r from-transparent via-background/40 to-transparent")
        div(class: "absolute inset-x-0 top-[61cqw] h-[2.4cqw] -translate-y-1/2 bg-foreground/35 shadow-[0_1px_0_var(--background),0_-1px_0_var(--background)]")
        handle("top-[10cqw] h-[40cqw]")
        handle("top-[70cqw] h-[52cqw]")
        div(class: "absolute inset-x-0 bottom-[2.4cqw] flex justify-center") { nameplate }
        div(class: "absolute inset-y-0 right-0 w-[3cqw] bg-gradient-to-l from-foreground/20 to-transparent")
      end
    end

    def handle(position)
      div(class: "absolute right-[3.4cqw] w-[2.8cqw] rounded-full #{CHROME} #{position}")
    end

    def nameplate
      span(class: "inline-flex items-center gap-[1cqw] rounded-full px-[3cqw] py-[0.8cqw] text-[3cqw] font-bold uppercase tracking-[0.3em] text-foreground/70 #{CHROME}") do
        Icon(:chef_hat, class: "size-[3.6cqw]")
        plain "mise"
      end
    end

    # A scrawled arrow pointing at the headline; it goes away the first time a word moves.
    def hint
      div(data: { magnets_target: "hint" }, aria_hidden: "true",
          class: "pointer-events-none absolute left-(--x) top-(--y) z-10 -rotate-6 #{HAND} text-[4.4cqw] text-primary transition-opacity duration-500",
          style: "--x: 18%; --y: 40cqw") do
        plain "↑ the words move!"
      end
    end

    def photo
      recipe = @recipes.find { |candidate| candidate.image.attached? }
      Polaroid(recipe:) if recipe
    end

    # Two little feet and the shadow on the floor.
    def feet
      div(class: "pointer-events-none absolute inset-x-0 bottom-0", aria_hidden: "true") do
        div(class: "absolute inset-x-6 -bottom-1 h-3 rounded-full bg-foreground/25 blur-md")
        div(class: "absolute bottom-0 left-[9%] h-3 w-[14%] rounded-b-lg bg-foreground/70")
        div(class: "absolute bottom-0 right-[9%] h-3 w-[14%] rounded-b-lg bg-foreground/70")
      end
    end
end
