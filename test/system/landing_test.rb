require "application_system_test_case"

# The fridge door is play: drag, tick, tap. All of it is Stimulus, so it is tested in a browser, using it the way a person would.
class LandingSystemTest < ApplicationSystemTestCase
  setup do
    cook = create_user(name: "Maria")
    attach_image create_recipe(cook, name: "Lemon Chicken")
    %w[Pasta Risotto Soup].each { |name| create_recipe(cook, name: name) }
  end

  def overflow = page.evaluate_script("document.documentElement.scrollWidth - window.innerWidth")
  def magnet(text) = find("[data-magnets-target=magnet]", text:, exact_text: true)
  def spot(text) = magnet(text).native.rect

  # Presses on a magnet, moves by (dx, dy) pixels in small steps, and lets go.
  def drag(text, dx:, dy:)
    builder = page.driver.browser.action
    builder.move_to(magnet(text).native).click_and_hold
    5.times { builder.move_by(dx / 5, dy / 5) }
    builder.release.perform
  end

  test "it is a tall fridge: two doors, a seal between them, handles and a nameplate, on a phone and a desktop" do
    visit root_path
    door = find("[data-controller=magnets]").native.rect
    assert_operator door.height, :>, door.width * 1.4, "tall, like a fridge"
    assert_selector "span", text: "mise", visible: :all

    on_desktop do
      visit root_path
      wide = find("[data-controller=magnets]").native.rect
      assert_operator wide.height, :>, wide.width * 1.4, "still tall on a desktop"
      assert_operator wide.width, :<, 500, "not stretched across the screen"
    end
  end

  test "it fits a phone and a desktop without sideways scrolling" do
    visit root_path
    assert_selector "[data-magnets-target=magnet]", minimum: 10
    assert_operator overflow, :<=, 0, "phone"

    on_desktop do
      visit root_path
      assert_selector "[data-magnets-target=magnet]", minimum: 10
      assert_operator overflow, :<=, 0, "desktop"
    end
  end

  test "every magnet word stays inside the door on a phone and on a desktop" do
    inside = lambda do
      door = find("[data-controller=magnets]").native.rect
      all("[data-magnets-target=magnet], [data-controller=tick], [data-controller=dinner]").each do |element|
        box = element.native.rect
        assert_operator box.x, :>=, door.x - 6, "#{element.text.inspect} past the left edge"
        assert_operator box.x + box.width, :<=, door.x + door.width + 6, "#{element.text.inspect} past the right edge"
        assert_operator box.y + box.height, :<=, door.y + door.height + 6, "#{element.text.inspect} below the door"
      end
    end

    visit root_path
    sleep 1.2 # the words land one after another
    inside.call
    on_desktop do
      visit root_path
      sleep 1.2
      inside.call
    end
  end

  test "a word can be dragged, and the hint goes away once one has moved" do
    visit root_path
    sleep 1.2
    assert_selector "[data-magnets-target=hint]:not(.opacity-0)"
    before = spot("cook")

    drag("cook", dx: 60, dy: 40)

    after = spot("cook")
    assert_in_delta before.x + 60, after.x, 25
    assert_in_delta before.y + 40, after.y, 25
    assert_selector "[data-magnets-target=hint].opacity-0", visible: :all
  end

  test "a word dropped beside another snaps onto its end, so a sentence lines up" do
    visit root_path
    sleep 1.2
    target = spot("dinner,")
    mine = spot("cook")

    # Drop "cook" just after "dinner," and a little off its line.
    drag("cook", dx: (target.x + target.width + 6 - mine.x).round, dy: (target.y + 4 - mine.y).round)

    snapped = spot("cook")
    assert_in_delta target.y, snapped.y, 3, "same line"
    assert_in_delta target.x + target.width, snapped.x, 10, "right after it"
  end

  test "a word cannot be dragged out of the door" do
    visit root_path
    sleep 1.2
    mine = spot("slow")
    # Pull it to the very corner of the window, past the door's own edge.
    centre = [ mine.x + mine.width / 2, mine.y + mine.height / 2 ]
    drag("slow", dx: (page.evaluate_script("window.innerWidth") - centre[0] - 2).round, dy: (page.evaluate_script("window.innerHeight") - centre[1] - 2).round)
    door = find("[data-controller=magnets]").native.rect
    box = spot("slow")
    assert_operator box.x + box.width, :<=, door.x + door.width + 4
    assert_operator box.y + box.height, :<=, door.y + door.height + 4
  end

  test "words move with the arrow keys too" do
    visit root_path
    sleep 1.2
    before = spot("plan")
    magnet("plan").send_keys(:arrow_right, :arrow_right, :arrow_down)

    after = spot("plan")
    assert_in_delta before.x + 16, after.x, 4
    assert_in_delta before.y + 8, after.y, 4
  end

  test "ticking groceries crosses them off, and ticking them all says so" do
    visit root_path
    assert_no_selector "[data-controller=tick][data-done]"
    %w[lemons feta tomatoes].each { |item| click_button "· #{item}" }
    assert_selector "button[aria-pressed=true]", count: 3
    assert_no_selector "[data-controller=tick][data-done]"

    click_button "· rice"
    assert_selector "[data-controller=tick][data-done]"
    assert_text "all set!"

    click_button "· rice" # and it can be undone
    assert_no_selector "[data-controller=tick][data-done]"
  end

  test "the dinner note picks another dinner each time it is tapped" do
    visit root_path
    note = find("[data-controller=dinner]")
    first = note.find("[data-dinner-target=name]").text
    assert_includes %w[Lemon\ Chicken Pasta Risotto Soup], first

    seen = [ first ]
    8.times do
      note.click
      sleep 0.3
      seen << note.find("[data-dinner-target=name]").text
    end
    assert_operator seen.uniq.size, :>, 1, "it rolls different dinners"
    seen.each_cons(2) { |a, b| assert_not_equal a, b, "never the same one twice in a row" }
  end

  test "a color magnet restyles the whole page, fridge included" do
    visit root_path
    sleep 1
    light_door = page.evaluate_script("getComputedStyle(document.querySelector('[data-controller=magnets]')).backgroundImage")

    find("button[aria-label='Plum']").click
    assert_selector "html.dark[data-palette=plum]"
    assert_selector "button[aria-label=Plum][aria-pressed=true]"
    assert_not_equal light_door, page.evaluate_script("getComputedStyle(document.querySelector('[data-controller=magnets]')).backgroundImage")
  end

  test "Get started leads to sign up, Sign in to sign in, and the photo to its recipe" do
    visit root_path
    click_link "Get started"
    assert_current_path new_registration_path

    visit root_path
    click_link "Already have an account? Sign in"
    assert_current_path new_session_path

    visit root_path
    click_link "Open Lemon Chicken"
    assert_selector "h1", text: "Lemon Chicken"
  end

  test "the page has one heading for screen readers and the magnets are keyboard-reachable" do
    visit root_path
    assert_selector "h1", text: "Mise: dinner, decided.", visible: :all, count: 1
    assert_selector "[data-magnets-target=magnet][tabindex='0'][role=button]", minimum: 10
  end
end
