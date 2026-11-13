require "test_helper"

# Browser tests run in headless Chromium at phone size, since that is how the app is used.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 390, 844 ] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
  end

  # Icon-only and repeated buttons are named by aria-label, as a screen reader would hear them.
  setup { Capybara.enable_aria_label = true }

  def sign_in_through_form(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "secret123"
    click_button "Sign in"
    assert_current_path recipes_path
  end

  def on_desktop
    page.driver.browser.manage.window.resize_to(1280, 800)
    yield
  ensure
    page.driver.browser.manage.window.resize_to(390, 844)
  end

  # Sheets slide in; a click while one is still moving can land on the wrong row, so wait for it to settle.
  def assert_sheet_open
    assert_selector "[data-controller~=sheet]"
    page.document.synchronize do
      raise Capybara::ExpectationNotMet, "sheet is still animating" if page.evaluate_script("document.getAnimations().length").positive?
    end
  end

  # Lazy images below the fold never load in a short window, so load them all, then wait for every image to decode.
  def assert_images_loaded(count:)
    assert_selector "img", count:
    page.execute_script("document.querySelectorAll('img[loading=lazy]').forEach(img => img.loading = 'eager')")
    page.document.synchronize do
      loaded = page.evaluate_script("Array.from(document.images).every(img => img.complete && img.naturalWidth > 0)")
      raise Capybara::ExpectationNotMet, "some images did not load" unless loaded
    end
  end
end
