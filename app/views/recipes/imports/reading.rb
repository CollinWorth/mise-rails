# The sorting screen: shown when the text couldn't be read confidently, or when the cook asks to check how it was read.
class Views::Recipes::Imports::Reading < Views::Base
  def initialize(lines:, unsure:)
    @lines = lines
    @unsure = unsure
  end

  def view_template
    Narrow do
      PageHeader(title: "How I read it")
      Text { @unsure ? "I wasn't sure about some of this. Tap any line that's in the wrong place to change it, then build the recipe." : "Tap any line that's in the wrong place to change it, then build the recipe." }
      if @lines.none?
        EmptyState(title: "There's nothing to read", text: "Go back and paste the recipe text.") { Link(href: new_recipes_import_path, variant: :primary) { "Back to import" } }
      else
        LineSorter(lines: @lines) do
          Button(type: :submit, size: :lg) { "Build recipe" }
          Link(href: new_recipes_import_path, variant: :ghost) { "Start over" }
        end
      end
    end
  end
end
