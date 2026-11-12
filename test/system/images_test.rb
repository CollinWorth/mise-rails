require "application_system_test_case"

class ImagesTest < ApplicationSystemTestCase
  test "recipe photos render on discover and page two" do
    cook = create_user(name: "Maria")
    13.times { |n| attach_image create_recipe(cook, name: "Dish #{n}") }

    visit discover_path
    assert_images_loaded count: 12
    click_link "Next"
    assert_images_loaded count: 1
    assert_text "2 of 2"
  end

  test "uploading a photo while creating a recipe" do
    cook = create_user(name: "Maria")
    sign_in_through_form(cook)

    visit new_recipe_path
    fill_in "Name", with: "Toast"
    attach_file "Photo", file_fixture("dish.jpg")
    click_button "Save recipe"

    assert_text "Recipe saved."
    assert_images_loaded count: 1
  end
end
