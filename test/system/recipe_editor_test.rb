require "application_system_test_case"

class RecipeEditorTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    @recipe = create_recipe(@cook, name: "Lasagna", ingredients: [
      { name: "salt", quantity: "1", unit: "tsp" },
      { name: "Sauce", section: true }, { name: "tomato", quantity: "4" }, { name: "basil", quantity: "1", unit: "bunch" },
      { name: "Dough", section: true }, { name: "flour", quantity: "2", unit: "cups" }
    ])
    @recipe.update!(instructions: "Make the sauce.\nMake the dough.\nLayer and bake.")
    sign_in_through_form(@cook)
  end

  def names = all("[data-nested-form-target=item] input[name$='[name]']").map(&:value)
  def row_for(value) = all("[data-nested-form-target=item]").find { |row| row.find("input[name$='[name]']").value == value }
  def handle_for(value) = row_for(value).find("[data-handle]")
  def saved_order = @recipe.reload.ingredients.reorder(:position).map(&:name)
  def steps = all("textarea[aria-label=Step]").map(&:value)

  def save
    click_button "Save recipe"
    assert_text "Recipe updated."
  end

  # ---- ingredients ----

  test "an ingredient moves up and down with the arrow keys on its grip, and the order is saved" do
    visit edit_recipe_path(@recipe)
    assert_equal %w[salt Sauce tomato basil Dough flour], names

    handle_for("basil").send_keys(:arrow_up)
    assert_equal %w[salt Sauce basil tomato Dough flour], names

    handle_for("salt").send_keys(:arrow_down, :arrow_down)
    assert_equal %w[Sauce basil salt tomato Dough flour], names, "a row can cross a section heading"

    save
    assert_equal %w[Sauce basil salt tomato Dough flour], saved_order
  end

  test "a section heading takes its ingredients with it when it moves" do
    visit edit_recipe_path(@recipe)

    handle_for("Dough").send_keys(:arrow_up)
    assert_equal %w[salt Dough flour Sauce tomato basil], names

    handle_for("Dough").send_keys(:arrow_down)
    assert_equal %w[salt Sauce tomato basil Dough flour], names

    save
    assert_equal %w[salt Sauce tomato basil Dough flour], saved_order
    assert @recipe.ingredients.find_by(name: "Dough").section?
  end

  test "a section can't go above the loose rows at the top, which would turn them into part of it" do
    visit edit_recipe_path(@recipe)
    handle_for("Sauce").send_keys(:arrow_up)
    assert_equal %w[salt Sauce tomato basil Dough flour], names
  end

  test "a section at the edge doesn't move off the list" do
    visit edit_recipe_path(@recipe)
    handle_for("Dough").send_keys(:arrow_down)
    handle_for("salt").send_keys(:arrow_up)
    assert_equal %w[salt Sauce tomato basil Dough flour], names
  end

  # A real mouse drag between two grips, with both in view (the sticky header would otherwise cover them).
  def drag(from, to, offset: 6)
    page.execute_script("window.scrollTo(0, 0); arguments[0].scrollIntoView({ block: 'center' })", handle_for(from).native)
    sleep 0.2
    page.driver.browser.action.move_to(handle_for(from).native).click_and_hold.move_by(0, -6).move_by(0, -20).move_by(0, -30)
      .move_to(handle_for(to).native, 0, offset).move_to(handle_for(to).native, 0, offset - 2).release.perform
  end

  test "dragging a grip moves the row up the list" do
    visit edit_recipe_path(@recipe)
    drag("flour", "tomato", offset: -6)
    assert_operator names.index("flour"), :<, 5, "flour left the bottom"

    moved_to = names.index("flour")
    save
    assert_equal moved_to, saved_order.index("flour"), "and keeps its new place when saved"
  end

  test "dragging a section heading onto another heading moves it with its rows" do
    visit edit_recipe_path(@recipe)
    drag("Dough", "Sauce", offset: -6)

    assert_equal %w[salt Dough flour Sauce tomato basil], names
  end

  # What the list does with the drag events it is sent (the drag library itself is Sortable, which is tested upstream).
  def drag_events(item_value, &)
    page.execute_script(<<~JS, find("input[value='#{item_value}']").ancestor("[data-nested-form-target=item]").native)
      window.__list = document.querySelector("[data-nested-form-target=list]")
      window.__item = arguments[0]
      window.__send = (name, detail, cancelable = false) => {
        const event = new CustomEvent("reorder:" + name, { detail: { item: window.__item, ...detail }, bubbles: true, cancelable })
        window.__list.dispatchEvent(event)
        return event.defaultPrevented
      }
    JS
    yield
  end

  test "dragging a heading collapses its rows, and dropping it puts them back right below it" do
    visit edit_recipe_path(@recipe)
    drag_events("Dough") do
      page.execute_script("__send('start', {})")
      assert_equal %w[salt Sauce tomato basil Dough], names.reject(&:blank?), "its rows are tucked away while it's carried"
      assert_equal 5, all("[data-nested-form-target=item]").size

      page.execute_script("__list.insertBefore(__item, document.querySelector(\"input[value='Sauce']\").closest('[data-nested-form-target=item]')); __send('end', {})")
    end

    assert_equal %w[salt Dough flour Sauce tomato basil], names
    save
    assert_equal %w[salt Dough flour Sauce tomato basil], saved_order
  end

  test "a heading is still carried whole when the drag moves before its start event arrives" do
    visit edit_recipe_path(@recipe)
    drag_events("Dough") do
      page.execute_script("__send('move', { related: document.querySelector(\"input[value='Sauce']\").closest('[data-nested-form-target=item]'), after: false }, true)")
      page.execute_script("__list.insertBefore(__item, document.querySelector(\"input[value='Sauce']\").closest('[data-nested-form-target=item]')); __send('end', {})")
    end

    assert_equal %w[salt Dough flour Sauce tomato basil], names
  end

  test "a heading can be dropped before another heading or at the end, never inside a group or above the loose rows" do
    visit edit_recipe_path(@recipe)
    drag_events("Dough") do
      refused = lambda do |value, after|
        page.evaluate_script("__send('move', { related: document.querySelector(\"input[value='#{value}']\").closest('[data-nested-form-target=item]'), after: #{after} }, true)")
      end
      assert refused.call("basil", false), "before basil is inside the Sauce group"
      assert refused.call("tomato", false), "before tomato is inside the Sauce group"
      assert refused.call("salt", false), "above the loose rows"
      assert_not refused.call("Sauce", false), "just before the Sauce heading"
      assert_not refused.call("basil", true), "after the last row of the list"
    end
  end

  test "Return inserts the new ingredient right below the one you're in" do
    visit edit_recipe_path(@recipe)
    find("input[value=tomato]").send_keys(:enter) # moves on to basil
    find("input[value=basil]").send_keys(:enter)  # moves on to the Dough heading
    page.driver.browser.switch_to.active_element.send_keys(:enter)
    assert_equal %w[salt Sauce tomato basil Dough flour], names

    find("input[value=flour]").send_keys(:enter) # the last row adds one below
    assert_equal 7, names.size
    assert_equal "flour", names[5]
    assert_equal "", names[6]
  end

  test "new rows and added sections can be moved too, and keep their place when saved" do
    visit edit_recipe_path(@recipe)
    click_button "Add section"
    all("input[placeholder^=Section]").last.set("Topping")
    click_button "Add ingredient"
    all("input[placeholder=Ingredient]").last.set("cheese")

    handle_for("Topping").send_keys(:arrow_up, :arrow_up)
    assert_equal %w[salt Topping cheese Sauce tomato basil Dough flour], names

    save
    assert_equal %w[salt Topping cheese Sauce tomato basil Dough flour], saved_order
  end

  # ---- instructions ----

  test "the instructions are a numbered list of steps, not one box" do
    visit edit_recipe_path(@recipe)
    assert_equal [ "Make the sauce.", "Make the dough.", "Layer and bake." ], steps
    assert_equal %w[1 2 3], all("[data-steps-target=number]").map(&:text)
  end

  test "Return starts the next step, splitting at the cursor" do
    visit edit_recipe_path(@recipe)
    box = all("textarea[aria-label=Step]").first
    box.send_keys(:home, *([ :arrow_right ] * 5), :enter) # after "Make "

    assert_equal [ "Make ", "the sauce.", "Make the dough.", "Layer and bake." ], steps
    assert_equal "the sauce.", page.evaluate_script("document.activeElement.value")
    assert_equal page.evaluate_script("document.activeElement.selectionStart"), 0
  end

  test "Backspace at the start of a step joins it to the one above" do
    visit edit_recipe_path(@recipe)
    all("textarea[aria-label=Step]")[1].send_keys(:home, :backspace)

    assert_equal [ "Make the sauce.Make the dough.", "Layer and bake." ], steps
  end

  test "pasting several lines makes a step of each" do
    visit edit_recipe_path(@recipe)
    box = all("textarea[aria-label=Step]").last
    box.send_keys(:end)
    page.execute_script(<<~JS, box.native)
      const data = new DataTransfer()
      data.setData("text", " Cool it.\\n  Slice.\\n\\nServe.")
      arguments[0].dispatchEvent(new ClipboardEvent("paste", { clipboardData: data, bubbles: true, cancelable: true }))
    JS

    assert_equal [ "Make the sauce.", "Make the dough.", "Layer and bake.Cool it.", "Slice.", "Serve." ], steps
  end

  test "a step's box grows with its text, so there is nothing to drag or scroll" do
    visit edit_recipe_path(@recipe)
    box = all("textarea[aria-label=Step]").first
    before = box.native.size.height

    box.send_keys(" and keep stirring slowly until the sauce thickens and coats the back of a spoon, then season with salt and pepper to taste and set aside")
    assert_operator box.native.size.height, :>, before + 20
    assert_no_selector "textarea[aria-label=Step][style*='resize']"
    assert_equal box.native.property("scrollHeight"), box.native.size.height.round
  end

  test "steps move with the arrow keys on their grip, can be added and removed, and are saved in order" do
    visit edit_recipe_path(@recipe)
    find_all("[data-steps-target=item] [data-handle]").last.send_keys(:arrow_up)
    assert_equal [ "Make the sauce.", "Layer and bake.", "Make the dough." ], steps
    assert_equal %w[1 2 3], all("[data-steps-target=number]").map(&:text)

    click_button "Add step"
    page.driver.browser.switch_to.active_element.send_keys("Rest ten minutes.")
    all("button[aria-label='Remove step']").first.click
    assert_equal [ "Layer and bake.", "Make the dough.", "Rest ten minutes." ], steps

    save
    assert_equal "Layer and bake.\nMake the dough.\nRest ten minutes.", @recipe.reload.instructions
    assert_text "Rest ten minutes."
  end

  test "empty steps are dropped when saving, and removing the last step leaves a blank one to type in" do
    visit edit_recipe_path(@recipe)
    click_button "Add step"
    click_button "Add step"
    save
    assert_equal "Make the sauce.\nMake the dough.\nLayer and bake.", @recipe.reload.instructions

    visit edit_recipe_path(@recipe)
    3.times { all("button[aria-label='Remove step']").first.click }
    assert_equal [ "" ], steps
  end

  test "a new recipe starts with one blank step" do
    visit new_recipe_path
    assert_equal [ "" ], steps
  end
end
