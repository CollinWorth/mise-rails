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
end
