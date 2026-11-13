# What a new visitor sees at the front door: a big promise, then the app's own screens (drawn small) showing how a recipe
# becomes a week of dinners and one grocery list. Every color comes from the active theme, and a row of theme tiles lets
# visitors try them on the page itself. Real public recipes fill the collage and the scrolling strip.
class Views::Landing::Show < Views::Base
  SAMPLES = [ "Honey Garlic Tofu", "Spaghetti Carbonara", "Chicken Tikka Masala", "Beef Tacos", "Pad Thai", "Banana Bread" ].freeze
  GRADIENT = "bg-gradient-to-r from-primary via-brand-2 to-brand-3 bg-clip-text text-transparent"

  def initialize(recipes:)
    @recipes = recipes
  end

  def bleed? = true

  def view_template
    hero
    how_it_works
    community if @recipes.size >= 3
    themes
    closing
    footer_links
  end

  private
    # ---------- hero ----------

    def hero
      section(class: "relative overflow-hidden") do
        glow("-left-24 -top-28 size-96 bg-primary/25", delay: "0s")
        glow("right-[-4rem] top-1/3 size-80 bg-brand-2/25", delay: "-5s")
        glow("bottom-[-5rem] left-1/3 size-72 bg-brand-3/25", delay: "-9s")

        div(class: "relative mx-auto grid max-w-6xl items-center gap-12 px-4 pb-20 pt-12 lg:grid-cols-[1.05fr_1fr] lg:pb-28 lg:pt-24") do
          div(class: "flex flex-col items-start gap-6") do
            span(class: "rise inline-flex items-center gap-2 rounded-full border bg-card/70 px-3 py-1 text-xs font-medium text-muted-foreground backdrop-blur") do
              Icon(:chef_hat, class: "size-4 text-primary")
              plain "Recipes · Meal plans · Groceries"
            end
            h1(class: "rise text-5xl font-extrabold leading-[1.02] tracking-tight sm:text-6xl lg:text-7xl", style: "--delay: .08s") do
              plain "Dinner,"
              br
              span(class: GRADIENT) { "decided." }
            end
            p(class: "rise max-w-lg text-lg text-muted-foreground", style: "--delay: .16s") { "Save recipes from anywhere, plan your week, and get a grocery list that already knows what's in your pantry." }
            div(class: "rise flex flex-wrap items-center gap-3", style: "--delay: .24s") do
              Link(href: new_registration_path, variant: :primary, size: :xl, class: "rounded-full shadow-lg shadow-primary/30") { "Get started" }
              Link(href: discover_path, variant: :outline, size: :xl, class: "rounded-full bg-card/70 backdrop-blur") { "Browse recipes" }
            end
            p(class: "rise text-sm text-muted-foreground", style: "--delay: .3s") do
              plain "Already cooking with Mise? "
              TextLink(href: new_session_path, class: "font-medium text-foreground underline") { "Sign in" }
            end
          end
          collage
        end
      end
    end

    def glow(position, delay:)
      div(class: [ "drift-blob pointer-events-none absolute rounded-full blur-3xl", position ], style: "--delay: #{delay}", aria_hidden: "true")
    end

    # Four tilted recipe cards that bob gently; real public recipes when there are any, sample dishes otherwise.
    def collage
      spots = [
        [ "left-0 top-10 w-[52%]", "-6deg", "0s", "9s" ],
        [ "right-0 top-0 w-[50%]", "5deg", "-3s", "11s" ],
        [ "bottom-8 left-[2%] w-[48%]", "4deg", "-6s", "10s" ],
        [ "bottom-0 right-0 w-[52%]", "-4deg", "-8s", "12s" ]
      ]
      div(class: "relative mx-auto h-[26rem] w-full max-w-md sm:h-[30rem] lg:h-[34rem]", data: { controller: "reveal" }) do
        hero_recipes.zip(spots).each do |recipe, (position, tilt, delay, duration)|
          div(class: [ "float-card absolute", position ], style: "--tilt: #{tilt}; --delay: #{delay}; --duration: #{duration}; transform: rotate(#{tilt})") do
            div(class: "overflow-hidden rounded-2xl border bg-card shadow-xl shadow-foreground/10") do
              RecipeImage(recipe:, eager: true)
              div(class: "flex flex-col gap-1 p-3") do
                span(class: "truncate text-sm font-semibold") { recipe.name }
                span(class: "text-xs text-brand-2") { recipe.total_time.positive? ? "#{recipe.total_time} min" : "Dinner" }
              end
            end
          end
        end
      end
    end

    def hero_recipes = (@recipes.first(4) + SAMPLES.map { |name| Recipe.new(name:) }).first(4)

    # ---------- how it works ----------

    def how_it_works
      section(class: "mx-auto max-w-6xl px-4 py-16 lg:py-24") do
        heading("From a link to dinner, in three taps.", "Mise does the busywork between finding a recipe and putting it on the table.")
        div(class: "grid gap-6 md:grid-cols-3") do
          step(1, "Paste a link. Get a recipe.", "Found something good online? Drop in the address and Mise pulls out the ingredients and steps. Fix anything, then save it.", delay: "0s") { import_mock }
          step(2, "Drop it on a day.", "Tap + on any recipe and pick the night. Planning for guests? Scale it with one number.", delay: ".1s") { planner_mock }
          step(3, "Shop once.", "Your week becomes one grocery list, sorted by aisle. Things you always have, like salt and oil, stay off it.", delay: ".2s") { grocery_mock }
        end
      end
    end

    def heading(title, subtitle)
      div(class: "mx-auto mb-12 flex max-w-2xl flex-col gap-3 text-center", data: { controller: "reveal" }) do
        h2(class: "text-3xl font-bold tracking-tight sm:text-4xl") { title }
        p(class: "text-lg text-muted-foreground") { subtitle }
      end
    end

    def step(number, title, text, delay:, &visual)
      div(class: "flex flex-col gap-5 rounded-3xl border bg-card p-5 shadow-sm", data: { controller: "reveal" }, style: "--delay: #{delay}") do
        div(class: "min-h-64 rounded-2xl bg-muted p-4", aria_hidden: "true", &visual)
        div(class: "flex flex-col gap-2") do
          span(class: "flex size-8 items-center justify-center rounded-full bg-brand-2 text-sm font-bold text-brand-2-foreground") { number }
          h3(class: "text-xl font-semibold tracking-tight") { title }
          p(class: "text-muted-foreground") { text }
        end
      end
    end

    # a web address, and the recipe it turns into
    def import_mock
      div(class: "flex flex-col gap-3") do
        div(class: "flex items-center gap-2 rounded-xl border bg-card px-3 py-2.5 text-sm shadow-sm") do
          Icon(:link, class: "size-4 text-brand-2")
          span(class: "truncate text-muted-foreground") { "kitchen.example/best-lasagna" }
          span(class: "caret -ml-1 inline-block h-4 w-px bg-foreground")
        end
        div(class: "flex flex-col gap-2.5 rounded-xl border bg-card p-3.5 shadow-sm") do
          span(class: "font-semibold") { "Best Lasagna" }
          div(class: "flex gap-1.5") do
            span(class: "rounded-full border border-brand-2/30 bg-brand-2/10 px-2 py-0.5 text-xs text-brand-2") { "Prep 20 min" }
            span(class: "rounded-full border border-brand-3/30 bg-brand-3/10 px-2 py-0.5 text-xs text-brand-3") { "Italian" }
          end
          [ "500 g beef mince", "2 cups tomato sauce", "9 lasagna sheets" ].each do |line|
            div(class: "flex items-center gap-2 text-sm") { span(class: "size-3.5 rounded-sm border border-muted-foreground/40"); span { line } }
          end
        end
      end
    end

    # a few evenings with dinner on them
    def planner_mock
      div(class: "flex flex-col gap-2.5") do
        [ [ "Mon", "Lasagna", "×2" ], [ "Wed", "Chicken tacos", nil ], [ "Fri", "Pad Thai", nil ] ].each_with_index do |(day, meal, times), index|
          div(class: "flex items-center gap-3") do
            span(class: "w-9 text-xs font-medium uppercase tracking-wide text-muted-foreground") { day }
            div(class: "flex flex-1 items-center gap-2.5 rounded-xl border bg-card p-2 shadow-sm") do
              span(class: [ "size-8 shrink-0 rounded-lg bg-gradient-to-br", [ "from-primary/40 to-brand-2/30", "from-brand-2/40 to-brand-3/30", "from-brand-3/40 to-primary/30" ][index] ])
              span(class: "flex-1 truncate text-sm font-medium") { meal }
              span(class: "text-xs font-medium text-brand-3") { times } if times
            end
          end
        end
        div(class: "ml-12 rounded-xl border border-dashed py-2 text-center text-xs text-muted-foreground") { "+ Add" }
      end
    end

    # items that tick themselves off, and one that was skipped because it's in the pantry
    def grocery_mock
      div(class: "flex flex-col gap-3") do
        span(class: "text-sm font-semibold text-brand-2") { "Dairy & Eggs" }
        [ [ "milk", "1 gallon", "0.4s" ], [ "eggs", "12", "0.9s" ] ].each { |name, amount, delay| grocery_row(name, amount, ticked: true, delay:) }
        span(class: "mt-1 text-sm font-semibold text-brand-2") { "Produce" }
        grocery_row("tomatoes", "4", ticked: false)
        div(class: "flex items-center gap-3 rounded-xl border border-dashed px-3 py-2 text-sm text-muted-foreground") do
          Icon(:basket, class: "size-4")
          span(class: "flex-1 truncate") { "salt" }
          span(class: "text-xs") { "in your pantry, so skipped" }
        end
      end
    end

    def grocery_row(name, amount, ticked:, delay: "0s")
      div(class: "flex items-center gap-3 rounded-xl border bg-card px-3 py-2 shadow-sm") do
        span(class: [ "flex size-5 shrink-0 items-center justify-center rounded-full border-2", (ticked ? "border-brand-2 bg-brand-2 text-brand-2-foreground tick-in" : "border-muted-foreground/40") ], style: ("--delay: #{delay}" if ticked)) do
          Icon(:check, class: "size-3") if ticked
        end
        span(class: [ "flex-1 text-sm font-medium", ("text-muted-foreground line-through" if ticked) ]) { name }
        span(class: "text-xs text-muted-foreground") { amount }
      end
    end

    # ---------- community strip ----------

    def community
      items = @recipes * (8.0 / @recipes.size).ceil
      section(class: "py-12 lg:py-16") do
        div(class: "mx-auto mb-8 max-w-6xl px-4", data: { controller: "reveal" }) do
          h2(class: "text-2xl font-bold tracking-tight sm:text-3xl") { "Fresh from the community" }
          p(class: "text-muted-foreground") { "Public recipes from cooks on Mise. Tap one to see how it's written up." }
        end
        div(class: "marquee overflow-hidden [mask-image:linear-gradient(to_right,transparent,black_8%,black_92%,transparent)]") do
          div(class: "marquee-track", style: "--duration: #{items.size * 7}s") do
            (items + items).each_with_index { |recipe, index| strip_card(recipe, hidden: index >= items.size) }
          end
        end
      end
    end

    def strip_card(recipe, hidden:)
      a(href: recipe_path(recipe), class: "block w-60 shrink-0 overflow-hidden rounded-2xl border bg-card shadow-sm transition hover:-translate-y-0.5 hover:shadow-md", tabindex: (-1 if hidden), aria_hidden: (hidden ? "true" : nil)) do
        RecipeImage(recipe:)
        div(class: "flex flex-col p-3") do
          span(class: "truncate text-sm font-semibold") { recipe.name }
          span(class: "truncate text-xs text-muted-foreground") { "by #{recipe.user.name}" }
        end
      end
    end

    # ---------- themes ----------

    def themes
      section(class: "mx-auto max-w-6xl px-4 py-16 lg:py-24", data: { controller: "landing-palette" }) do
        heading("Make it yours.", "Light, dark, or whatever your phone is doing. Pick colors you like. Try one now, the whole page changes.")
        div(class: "flex flex-col gap-6", data: { controller: "reveal" }) do
          theme_row("Light", Palette::LIGHT, mode: "light")
          theme_row("Dark", Palette::DARK, mode: "dark")
        end
      end
    end

    def theme_row(label, options, mode:)
      div(class: "flex flex-col gap-3") do
        span(class: "text-sm font-medium text-muted-foreground") { label }
        div(class: "grid grid-cols-2 gap-3 sm:grid-cols-4") do
          options.each do |key, name|
            button(type: :button, data: { palette: key, mode:, landing_palette_target: "tile", action: "landing-palette#choose" }, aria: { pressed: "false" },
                   class: "flex flex-col gap-2 rounded-2xl border-2 bg-background p-4 text-left text-foreground shadow-sm transition hover:-translate-y-0.5 hover:shadow-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring aria-pressed:border-primary") do
              div(class: "flex gap-1.5") do
                span(class: "size-5 rounded-full bg-primary")
                span(class: "size-5 rounded-full bg-brand-2")
                span(class: "size-5 rounded-full bg-brand-3")
                span(class: "size-5 rounded-full border bg-card")
              end
              span(class: "text-sm font-medium") { name }
            end
          end
        end
      end
    end

    # ---------- closing ----------

    def closing
      section(class: "mx-auto max-w-6xl px-4 pb-16 lg:pb-24") do
        div(class: "relative overflow-hidden rounded-3xl bg-primary px-6 py-14 text-center text-primary-foreground shadow-xl shadow-primary/20 sm:py-20", data: { controller: "reveal" }) do
          div(class: "drift-blob pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-white/15 blur-2xl", aria_hidden: "true")
          div(class: "drift-blob pointer-events-none absolute -bottom-20 -left-10 size-72 rounded-full bg-black/10 blur-2xl", style: "--delay: -6s", aria_hidden: "true")
          div(class: "relative mx-auto flex max-w-xl flex-col items-center gap-5") do
            Icon(:chef_hat, class: "size-10")
            h2(class: "text-3xl font-extrabold tracking-tight sm:text-5xl") { "Ready when you are." }
            p(class: "text-lg opacity-90") { "Your recipes, your week, your grocery list. All in one place, ready on your phone." }
            Link(href: new_registration_path, variant: :secondary, size: :xl, class: "rounded-full bg-background text-foreground shadow-lg hover:bg-background/90") { "Create your account" }
          end
        end
      end
    end

    def footer_links
      footer(class: "border-t py-8") do
        div(class: "mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-4 px-4 text-sm text-muted-foreground") do
          span(class: "inline-flex items-center gap-2 font-semibold text-foreground") { Icon(:chef_hat, class: "size-4 text-primary"); plain "Mise" }
          nav(class: "flex gap-5") do
            TextLink(href: discover_path, class: "text-muted-foreground") { "Browse recipes" }
            TextLink(href: new_session_path, class: "text-muted-foreground") { "Sign in" }
            TextLink(href: new_registration_path, class: "text-muted-foreground") { "Sign up" }
          end
        end
      end
    end
end
