class Views::ShortcutKeys::Show < Views::Base
  def initialize(key:)
    @key = key
  end

  def view_template
    Narrow do
      PageHeader(title: "Siri Shortcut")
      Card do
        CardHeader do
          CardTitle { "Your key" }
          CardDescription { "Shown once. Copy it now: touch and hold, then Copy. Making a new key stops the old one working." }
        end
        CardContent { Input(value: @key, readonly: true, aria: { label: "Shortcut key" }, class: "font-mono") }
      end
      setup_card("Add to grocery list, with Siri", grocery_steps)
      setup_card("Send a recipe to Mise from any page", share_steps)
      Link(href: profile_path, variant: :outline) { "Done" }
    end
  end

  private
    def setup_card(title, steps)
      Card do
        CardHeader { CardTitle { title } }
        CardContent { Stack { steps.each_with_index { |step, index| Text { "#{index + 1}. #{step}" } } } }
      end
    end

    def grocery_steps
      [
        "Open Shortcuts, tap +, and name it “Add to grocery list”. That name is what you say: “Hey Siri, add to grocery list”.",
        "Add the action “Ask for Input” and set it to Text, with the question “What should I add?”.",
        "#{post_step(shortcuts_grocery_items_path)} Add a Text field named “text” whose value is the Provided Input.",
        "Add “Get Dictionary Value” for the key “message”, then “Speak Text” to hear the answer.",
        "Say it your way: “milk, 2 lb chicken thighs” adds two items, and amounts and units are read."
      ]
    end

    def share_steps
      [
        "In Shortcuts tap +, name it “Send to Mise”, then tap the info button and turn on “Show in Share Sheet”. Set it to accept URLs and Safari web pages only.",
        "#{post_step(shortcuts_recipe_imports_path)} Add a Text field named “url” whose value is the Shortcut Input.",
        "Add “Get Dictionary Value” for the key “message”, then “Show Result”. To open the recipe instead, get the key “url” and add “Open URLs”.",
        "Now in Safari (or any app) tap Share, then “Send to Mise”. The recipe is saved as a private recipe of yours."
      ]
    end

    # The "Get Contents of URL" settings both Shortcuts share.
    def post_step(path)
      "Add “Get Contents of URL” with the URL #{absolute_url(path)}, tap the arrow, set Method to POST, add the header “Authorization” with the value “Bearer ” followed by your key, and set Request Body to JSON."
    end
end
