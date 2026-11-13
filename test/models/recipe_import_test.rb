require "test_helper"

class RecipeImportTest < ActiveSupport::TestCase
  PAGE = <<~HTML
    <html><head><script type="application/ld+json">
      {"@type":"Recipe","name":"Apple Pie","recipeIngredient":["2 apples","1 cup sugar"],"recipeInstructions":"Bake it."}
    </script></head></html>
  HTML

  test "importing from a URL remembers where it came from" do
    page = Struct.new(:body).new(PAGE)

    attributes = RemoteFetch.stub(:get, page) { RecipeImport.new(url: " https://example.com/pie ").attributes }

    assert_equal "Apple Pie", attributes[:name]
    assert_equal "https://example.com/pie", attributes[:source_url]
    assert_equal 2, attributes[:ingredients_attributes].size
  end

  test "pasted text has no source" do
    attributes = RecipeImport.new(text: "Toast\nIngredients\nbread\nInstructions\nToast it.").attributes
    assert_nil attributes[:source_url]
  end


  def import_page(json_ld, url: "https://example.com/r")
    page = Struct.new(:body).new(%(<html><head><script type="application/ld+json">#{json_ld}</script></head></html>))
    RemoteFetch.stub(:get, page) { RecipeImport.new(url:).attributes }
  end

  test "it needs either an address or some text" do
    error = assert_raises(RecipeImport::Failed) { RecipeImport.new({}).attributes }
    assert_match(/Enter a web address or paste the recipe/, error.message)
  end

  test "a page with no recipe data says so" do
    page = Struct.new(:body).new("<html><body>Just a blog post</body></html>")
    error = assert_raises(RecipeImport::Failed) { RemoteFetch.stub(:get, page) { RecipeImport.new(url: "https://example.com").attributes } }
    assert_match(/No recipe found/, error.message)
  end

  test "an address that can't be fetched is reported as a failure, with the reason" do
    refuse = ->(*) { raise RemoteFetch::Refused, "That address isn't allowed." }
    error = assert_raises(RecipeImport::Failed) { RemoteFetch.stub(:get, refuse) { RecipeImport.new(url: "http://10.0.0.1").attributes } }
    assert_equal "That address isn't allowed.", error.message
  end

  test "recipe data inside an @graph, after a broken script, is still found" do
    page = Struct.new(:body).new(<<~HTML)
      <script type="application/ld+json">{ not json</script>
      <script type="application/ld+json">{"@graph":[{"@type":"WebSite"},{"@type":["Recipe"],"name":"Soup","recipeIngredient":["1 onion"]}]}</script>
    HTML
    attributes = RemoteFetch.stub(:get, page) { RecipeImport.new(url: "https://example.com").attributes }
    assert_equal "Soup", attributes[:name]
  end

  test "times, servings, cuisine and the photo are read from the usual schema.org shapes" do
    attributes = import_page({ "@type" => "Recipe", "name" => "Pie", "prepTime" => "PT20M", "cookTime" => "PT1H5M", "recipeYield" => [ "8 servings", "8" ],
                               "recipeCuisine" => [ "French" ], "recipeCategory" => "Dessert", "image" => [ { "url" => "https://example.com/pie.jpg" } ], "recipeIngredient" => [] }.to_json)

    assert_equal [ 20, 65, 8, "French", "Dessert", "https://example.com/pie.jpg" ],
                 attributes.values_at(:prep_time, :cook_time, :servings, :cuisine, :category, :image_url)
  end

  test "a time it can't read is left blank, and a plain photo address is kept" do
    attributes = import_page({ "@type" => "Recipe", "name" => "Pie", "prepTime" => "a while", "image" => "https://example.com/pie.png", "recipeIngredient" => [] }.to_json)

    assert_nil attributes[:prep_time]
    assert_equal "https://example.com/pie.png", attributes[:image_url]
  end

  test "instructions in every shape become one step per line, with entities decoded" do
    steps = {
      "text" => "Mix.\nBake.",
      "list" => [ "Mix &amp; stir", "Bake" ],
      "howto" => [ { "@type" => "HowToSection", "itemListElement" => [ { "@type" => "HowToStep", "text" => "Mix" }, { "@type" => "HowToStep", "text" => "Bake" } ] } ],
      "junk" => 42
    }
    assert_equal "Mix.\nBake.", import_page({ "@type" => "Recipe", "name" => "x", "recipeInstructions" => steps["text"], "recipeIngredient" => [] }.to_json)[:instructions]
    assert_equal "Mix & stir\nBake", import_page({ "@type" => "Recipe", "name" => "x", "recipeInstructions" => steps["list"], "recipeIngredient" => [] }.to_json)[:instructions]
    assert_equal "Mix\nBake", import_page({ "@type" => "Recipe", "name" => "x", "recipeInstructions" => steps["howto"], "recipeIngredient" => [] }.to_json)[:instructions]
    assert_equal "", import_page({ "@type" => "Recipe", "name" => "x", "recipeInstructions" => steps["junk"], "recipeIngredient" => [] }.to_json)[:instructions]
  end

  test "ingredient lines become a quantity, a unit and a name, and odd lines are kept whole" do
    attributes = import_page({ "@type" => "Recipe", "name" => "x", "recipeIngredient" => [ "1 1/2 cups flour", "salt to taste" ] }.to_json)
    flour, salt = attributes[:ingredients_attributes]

    assert_equal [ "flour", "1 1/2", "cup", 0 ], flour.values_at(:name, :quantity, :unit, :position)
    assert_equal "1", salt[:position].to_s
    assert_match(/salt/, salt[:name])
  end

  test "pasted text without headings puts numbered lines under ingredients and the rest under instructions" do
    attributes = RecipeImport.new(text: "Toast\n2 slices bread\n½ tsp salt\nToast it.\nButter it.").attributes

    assert_equal "Toast", attributes[:name]
    assert_equal [ "bread", "salt" ], attributes[:ingredients_attributes].map { |ingredient| ingredient[:name].split.last }
    assert_equal "Toast it.\nButter it.", attributes[:instructions]
  end
end
