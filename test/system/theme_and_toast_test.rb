require "application_system_test_case"

class ThemeAndToastSystemTest < ApplicationSystemTestCase
  def root(attribute) = page.evaluate_script("document.documentElement.#{attribute}")

  # The profile saves a moment after a choice; wait for that instead of racing it.
  def wait_until_saved(&condition)
    page.document.synchronize { raise Capybara::ExpectationNotMet, "not saved yet" unless condition.call }
  end

  # What the phone's own light/dark setting looks like to the page.
  def device_prefers(scheme)
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-color-scheme", value: scheme } ])
  end

  test "the page follows the device's light and dark setting, and changes with it" do
    device_prefers("light")
    visit discover_path
    assert_selector "html:not(.dark)"
    assert_equal Palette::DEFAULT_LIGHT, root("dataset.palette")

    device_prefers("dark")
    assert_selector "html.dark"
    assert_equal Palette::DEFAULT_DARK, root("dataset.palette")

    visit discover_path
    assert_selector "html.dark", wait: 3
    assert_no_selector "button[aria-label='Toggle theme']"
  end

  test "choosing Dark pins it whatever the device says, and it is remembered" do
    cook = create_user(name: "Maria")
    sign_in_through_form(cook)
    device_prefers("light")
    visit profile_path

    find("label", text: "Dark", exact_text: true).click
    assert_selector "html.dark"
    assert_text "Appearance updated."
    assert_equal "dark", cook.reload.appearance

    visit recipes_path
    assert_selector "html.dark"
  end

  test "choosing a light and a dark theme changes the colors at once and is remembered" do
    cook = create_user(name: "Maria")
    sign_in_through_form(cook)
    device_prefers("light")
    visit profile_path

    find("label", text: "Gruvbox Light").click
    assert_equal "gruvbox", root("dataset.palette")
    assert_text "Appearance updated."
    assert_equal "gruvbox", cook.reload.light_theme

    find("label", text: "Gruvbox Dark").click
    assert_equal "gruvbox", root("dataset.palette"), "the dark theme waits until dark is in use"
    device_prefers("dark")
    assert_selector "html.dark"
    assert_equal "gruvboxdark", root("dataset.palette")
    wait_until_saved { cook.reload.dark_theme == "gruvboxdark" }

    visit recipes_path
    assert_equal "gruvboxdark", root("dataset.palette")
    assert_equal "rgb(254, 128, 25)", page.evaluate_script("getComputedStyle(document.querySelector('a[href=\"#{new_recipe_path}\"]')).backgroundColor")
  end

  test "flash shows as a toast that goes away" do
    sign_in_through_form(create_user(name: "Maria"))
    visit new_recipe_path
    fill_in "Name", with: "Toast"
    click_button "Save recipe"

    assert_text "Recipe saved."
    assert_no_text "Recipe saved.", wait: 6
  end
end
