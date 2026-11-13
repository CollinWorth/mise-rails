class Views::Recipes::New < Views::Base
  # `lines` are the text lines a draft was built from (an import from text), so its reading can be checked again.
  def initialize(recipe:, lines: nil)
    @recipe = recipe
    @lines = lines
  end

  def view_template
    PageHeader(title: "New recipe")
    reading_notice if @lines.present?
    RecipeForm(recipe: @recipe)
  end

  private
    # Imported text is a guess, so the way back to the sorting screen is always one tap away.
    def reading_notice
      Alert do
        AlertDescription do
          ActionForm(action: recipes_import_path) do
            @lines.each_with_index do |line, index|
              input(type: :hidden, name: "lines[#{index}][text]", value: line.text)
              input(type: :hidden, name: "lines[#{index}][role]", value: line.role)
            end
            input(type: :hidden, name: "check", value: "1")
            Row(justify: :between) do
              Text(size: "2") { "Built from your text. Look it over, and fix any line that landed in the wrong place." }
              Button(type: :submit, variant: :outline, size: :sm) { "Check how I read it" }
            end
          end
        end
      end
    end
end
