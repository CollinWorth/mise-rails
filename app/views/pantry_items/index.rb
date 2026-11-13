class Views::PantryItems::Index < Views::Base
  def initialize(items:, suggestions:)
    @items = items
    @suggestions = suggestions
  end

  def view_template
    PageHeader(title: "Pantry") { Link(href: grocery_list_path, variant: :outline) { "Grocery list" } }
    Text { "Things you always have. They're left off your grocery list when you add a recipe or a week of meals." }
    add_form
    suggestions if @suggestions.any?
    list
  end

  private
    def add_form
      ActionForm(action: pantry_items_path) do
        Row(gap: :sm) do
          Input(name: "pantry_item[name]", placeholder: "Add something you always have", class: "min-w-0 flex-1 basis-48", required: true, autocapitalize: "none")
          Button(type: :submit) { "Add" }
        end
      end
    end

    def suggestions
      Stack(gap: :sm) do
        Heading(level: 4) { "Suggestions" }
        Row(gap: :sm) do
          @suggestions.each { |name| ButtonTo(action: pantry_items_path, params: { "pantry_item[name]" => name }) { "+ #{name}" } }
        end
      end
    end

    def list
      return Text { "Your pantry is empty." } if @items.none?

      Card do
        CardContent do
          Stack(gap: :sm) do
            @items.each do |item|
              Row(justify: :between) do
                Text { item.name }
                ButtonTo(action: pantry_item_path(item), method: :delete, variant: :ghost) { "Remove" }
              end
            end
          end
        end
      end
    end
end
