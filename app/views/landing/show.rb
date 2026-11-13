# What a new visitor sees at the front door: a big promise, then the app's own screens (drawn small) showing how a recipe
# becomes a week of dinners and one grocery list. It is only a composition of the Landing components; every color comes
# from the active theme, and real public recipes fill the collage and the scrolling strip.
class Views::Landing::Show < Views::Base
  def initialize(recipes:)
    @recipes = recipes
  end

  def bleed? = true

  def view_template
    Landing::Hero(recipes: @recipes)
    Landing::HowItWorks()
    Landing::Strip(recipes: @recipes) if @recipes.size >= 3
    Landing::Themes()
    Landing::Closing()
    Landing::Footer()
  end
end
