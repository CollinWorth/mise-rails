# The landing page's layout: the fridge, with the words about it (the block) beside it on a wide screen and below it on a phone.
class Components::Fridge::Stage < Components::Base
  def initialize(recipes:, dinners:)
    @recipes = recipes
    @dinners = dinners
  end

  def view_template(&copy)
    div(class: "mx-auto grid w-full max-w-5xl items-center gap-10 px-4 py-6 md:grid-cols-2 md:gap-16 md:py-12") do
      Door(recipes: @recipes, dinners: @dinners)
      Stack(gap: :lg, class: "items-center text-center md:order-first md:items-start md:text-left", &copy)
    end
  end
end
