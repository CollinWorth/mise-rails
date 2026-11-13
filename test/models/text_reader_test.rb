require "test_helper"

class TextReaderTest < ActiveSupport::TestCase
  def read(text) = RecipeImport::TextReader.new(text)
  def roles(text) = read(text).lines.map { |line| [ line.role, line.text ] }

  test "a recipe with the usual headings is read part by part, with details pulled out" do
    reader = read(<<~TEXT)
      Tomato Soup
      Serves 4
      Prep time: 10 min
      Cook time: 1 hour 15 minutes

      Ingredients
      2 tbsp olive oil
      1 onion, chopped
      salt
      For the garnish:
      1/2 cup cream

      Directions
      1. Heat the oil in a large
      pot over medium heat.
      2. Add the onion and cook until
      soft.
      3) Blend until smooth.
    TEXT

    assert_equal [ "title", "meta", "meta", "meta", "ingredient", "ingredient", "ingredient", "heading", "ingredient", "step", "step", "step" ], reader.lines.map(&:role)
    assert_equal "For the garnish", reader.lines.find { |line| line.role == "heading" }.text
    assert_equal [ "Heat the oil in a large pot over medium heat.", "Add the onion and cook until soft.", "Blend until smooth." ], reader.lines.select { |line| line.role == "step" }.map(&:text)
    assert_equal({ servings: 4, prep_time: 10, cook_time: 75 }, RecipeImport::TextReader.facts(reader.lines))
    assert reader.confident?
  end

  test "without any headings the shape of each line decides: amounts are ingredients, sentences are steps" do
    lines = roles("Grandma Pancakes\n2 cups flour\n1 egg\nmilk\nMix the flour and egg.\nCook on a griddle until golden.")
    assert_equal [ [ "title", "Grandma Pancakes" ], [ "ingredient", "2 cups flour" ], [ "ingredient", "1 egg" ], [ "ingredient", "milk" ], [ "step", "Mix the flour and egg." ], [ "step", "Cook on a griddle until golden." ] ], lines
  end

  test "a heading for the steps alone is enough to tell the ingredients before it" do
    assert_equal %w[title ingredient ingredient step step], read("Salad\n2 tomatoes\n1 cucumber\nDirections\nChop everything.\nToss.").lines.map(&:role)
  end

  test "an ALL CAPS title is a title, and a blurb before the ingredients is skipped" do
    lines = roles("BEST BROWNIES\nThese brownies are so fudgy you will make them every single week.\n2 eggs\n1 cup sugar\nBake at 350 for 25 minutes.")
    assert_equal [ "title", "skip", "ingredient", "ingredient", "step" ], lines.map(&:first)
  end

  test "bullets, step numbers and lone page numbers are cleaned away, and wrapped lines are glued back together" do
    lines = roles("• Chicken Curry\n• 500 g chicken\n• 1 (14 oz) can coconut milk,\nwell shaken\nMETHOD\nStep 1: Brown the chicken\n2\nAdd the coconut milk and simmer for\n20 minutes.\nNotes\nGreat with rice.")
    assert_equal [ [ "title", "Chicken Curry" ], [ "ingredient", "500 g chicken" ], [ "ingredient", "1 (14 oz) can coconut milk, well shaken" ],
                   [ "step", "Brown the chicken" ], [ "step", "Add the coconut milk and simmer for 20 minutes." ], [ "skip", "Great with rice." ] ], lines
  end

  test "short lines are never glued together, so a list of plain ingredients stays a list" do
    lines = roles("Toast\nbread\nbutter\nToast the bread.\nButter it.")
    assert_equal [ [ "title", "Toast" ], [ "step", "bread" ], [ "step", "butter" ], [ "step", "Toast the bread." ], [ "step", "Butter it." ] ], lines
  end

  test "one ingredient is enough when the text has headings to say so, but not when it is only a guess" do
    assert read("Tacos\nIngredients\n2 cups masa\nMethod\nMix well.").confident?
    assert_not read("Tacos\n2 cups masa\nMix well.").confident?
  end

  test "it is not confident when the ingredients or steps could not be found" do
    assert_not read("Toast\nbread\nbutter\nToast the bread.").confident?, "no amounts, so no ingredients"
    assert_not read("2 eggs\n1 cup sugar\nBake it.").confident?, "no title"
    assert_not read("Just a note to myself").confident?
    assert_equal [], read("  \n\n").lines
  end

  test "details: servings in a few phrasings, and times with hours, minutes or neither" do
    facts = ->(*texts) { RecipeImport::TextReader.facts(texts.map { |text| RecipeImport::TextReader::Line.new(text, "meta") }) }

    assert_equal({ servings: 6 }, facts.("Makes 6 cookies"))
    assert_equal({ servings: 4 }, facts.("Servings: 4-6"))
    assert_equal({ prep_time: 45 }, facts.("Prep: 45 min"))
    assert_equal({ cook_time: 90 }, facts.("Cook time: 1.5 hours"))
    assert_equal({ cook_time: 20 }, facts.("Bake time: 20"))
    assert_equal({}, facts.("Total time: 1 hour"))
  end

  test "a step that merely starts with Cook or Makes is not mistaken for a detail" do
    assert_equal %w[title ingredient ingredient step step], read("Eggs\n2 eggs\n1 tbsp butter\nCook on low heat until set.\nMakes sure to stir.").lines.map(&:role)
  end

  test "an amount like 1.5 cups is an ingredient, not a numbered step" do
    assert_equal [ "ingredient", "1.5 cups milk" ], roles("Pudding\n1.5 cups milk\n2 tbsp sugar\nWhisk well.")[1]
  end
end
