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
      Card do
        CardHeader { CardTitle { "Set it up in the Shortcuts app" } }
        CardContent do
          Stack do
            steps.each_with_index { |step, index| Text { "#{index + 1}. #{step}" } }
          end
        end
      end
      Link(href: profile_path, variant: :outline) { "Done" }
    end
  end

  private
    def steps
      [
        "Open Shortcuts, tap +, and name it “Add to grocery list”. That name is what you say: “Hey Siri, add to grocery list”.",
        "Add the action “Ask for Input” and set it to Text, with the question “What should I add?”.",
        "Add “Get Contents of URL”. URL: #{absolute_url(shortcuts_grocery_items_path)}. Tap the arrow to open it and set Method to POST.",
        "Under Headers add “Authorization” with the value “Bearer ” followed by your key.",
        "Set Request Body to JSON and add a Text field named “text” whose value is the Provided Input.",
        "Add “Get Dictionary Value” for the key “message”, then “Speak Text” (or “Show Result”) to hear the answer.",
        "Say it your way: “milk, 2 lb chicken thighs” adds two items, and amounts and units are read."
      ]
    end
end
