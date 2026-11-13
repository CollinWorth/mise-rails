# Four tilted recipe cards that bob gently: real public recipes when there are any, sample dishes to fill the rest.
class Components::Landing::Collage < Components::Base
  SAMPLES = [ "Honey Garlic Tofu", "Spaghetti Carbonara", "Chicken Tikka Masala", "Beef Tacos" ].freeze
  # position, tilt, animation delay, animation duration
  SPOTS = [
    [ "left-0 top-10 w-[52%]", "-6deg", "0s", "9s" ],
    [ "right-0 top-0 w-[50%]", "5deg", "-3s", "11s" ],
    [ "bottom-8 left-[2%] w-[48%]", "4deg", "-6s", "10s" ],
    [ "bottom-0 right-0 w-[52%]", "-4deg", "-8s", "12s" ]
  ].freeze

  def initialize(recipes:)
    @recipes = (recipes.first(4) + SAMPLES.map { |name| Recipe.new(name:) }).first(4)
  end

  def view_template
    div(class: "relative mx-auto h-[26rem] w-full max-w-md sm:h-[30rem] lg:h-[34rem]", data: { controller: "reveal" }) do
      @recipes.zip(SPOTS).each { |recipe, (position, tilt, delay, duration)| card(recipe, position:, tilt:, delay:, duration:) }
    end
  end

  private
    def card(recipe, position:, tilt:, delay:, duration:)
      div(class: [ "float-card absolute", position ], style: "--tilt: #{tilt}; --delay: #{delay}; --duration: #{duration}; transform: rotate(#{tilt})") do
        Card(class: "overflow-hidden rounded-2xl shadow-xl shadow-foreground/10") do
          RecipeImage(recipe:, eager: true)
          Stack(gap: :sm, class: "gap-1 p-3") do
            Text(as: "span", size: "2", weight: "semibold", class: "truncate") { recipe.name }
            Text(as: "span", size: "1", class: "text-brand-2") { recipe.total_time.positive? ? "#{recipe.total_time} min" : "Dinner" }
          end
        end
      end
    end
end
