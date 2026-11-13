# Where a recipe comes from: a web address, or text from anywhere (typed, copied, or scanned off a cookbook with the iPhone).
class Views::Recipes::Imports::New < Views::Base
  def view_template
    Narrow do
      PageHeader(title: "Import a recipe")
      Text(class: "text-muted-foreground") { "I'll build the recipe, then you can look it over and fix anything before it's saved." }
      from_a_page
      from_text
    end
  end

  private
    def from_a_page
      Card do
        CardHeader do
          CardTitle { "From a web page" }
          CardDescription { "Works with most recipe sites." }
        end
        CardContent do
          ActionForm(action: recipes_import_path) do
            Row(gap: :sm, class: "flex-nowrap") do
              Input(type: :url, name: "url", placeholder: "https://", aria: { label: "Web address" }, class: "min-w-0 flex-1", inputmode: "url", autocapitalize: "none", autocorrect: "off")
              Button(type: :submit) { "Import" }
            end
          end
        end
      end
    end

    def from_text
      Card do
        CardHeader do
          CardTitle { "From text or a photo" }
          CardDescription { "Paste a recipe from anywhere, or scan one from a cookbook or card." }
        end
        CardContent do
          Stack do
            how_to
            ActionForm(action: recipes_import_path, data: { controller: "paste" }) do
              Stack(gap: :sm) do
                TextAreaField(label: "Recipe text", name: "text", rows: 10, placeholder: "Paste or scan the recipe here", data: { paste_target: "field" })
                Row(gap: :sm) do
                  Button(type: :submit, size: :lg) { "Import" }
                  Button(type: :button, variant: :outline, size: :lg, data: { action: "paste#paste", paste_target: "button" }) { "Paste from clipboard" }
                end
              end
            end
          end
        end
      end
    end

    def how_to
      Stack(gap: :sm) do
        step_group("On an iPhone or iPad", [
          "Tap the box below, then touch and hold and choose Scan Text (older versions say Text from Camera).",
          "Point the camera at the recipe and tap Insert. Scan the next part the same way to add more.",
          "Or open a photo of the recipe in Photos, touch and hold the text, tap Copy, then come back and Paste."
        ])
        step_group("On a computer", [
          "Copy the recipe from a web page, PDF, email or document, then paste it into the box below."
        ])
        Text(size: "2", class: "text-muted-foreground") { "Lines like “Ingredients” and “Directions” help me tell the parts apart, but you don't need them. I'll ask you about anything I'm unsure of." }
      end
    end

    def step_group(title, steps)
      Stack(gap: :sm, class: "rounded-lg bg-muted/50 p-3") do
        Heading(level: 4) { title }
        steps.each { |text| Text(size: "2") { text } }
      end
    end
end
