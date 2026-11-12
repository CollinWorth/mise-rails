class Views::GroceryLists::Show < Views::Base
  def initialize(list:)
    @list = list
  end

  def view_template
    PageHeader(title: "Grocery list") do
      Link(href: planned_meals_path, variant: :outline) { "Plan meals" }
      ButtonTo(action: grocery_list_checked_items_path, method: :delete) { "Clear checked" } if @list.items.any?(&:checked?)
    end
    add_form
    return Text { "Your list is empty." } if @list.items.none?

    # Group by aisle in the order set in config/grocery_categories.yml
    by_category = @list.items.group_by(&:category)
    GroceryItem::CATEGORIES.each do |key, config|
      next unless (items = by_category[key])

      Card do
        CardHeader { CardTitle { config["label"] } }
        CardContent { Stack(gap: :sm) { items.each { |item| item_row(item) } } }
      end
    end
  end

  private
    def add_form
      ActionForm(action: grocery_list_items_path) do
        Row(gap: :sm) do
          Input(name: "item[quantity]", placeholder: "Qty", class: "w-20")
          Input(name: "item[unit]", placeholder: "Unit", class: "w-24")
          Input(name: "item[name]", placeholder: "Add an item", class: "w-64", required: true)
          Button(type: :submit) { "Add" }
        end
      end
    end

    def item_row(item)
      Row(justify: :between) do
        ActionForm(action: grocery_list_item_path(item), method: :patch, class: "flex items-center gap-2") do
          input(type: :hidden, name: "item[checked]", value: item.checked? ? "0" : "1")
          Button(type: :submit, variant: item.checked? ? :secondary : :outline, size: :sm) { item.checked? ? "☑" : "☐" }
          Text(class: item.checked? ? "line-through text-muted-foreground" : "") { [ item.quantity, item.unit, item.name ].compact_blank.join(" ") }
        end
        ButtonTo(action: grocery_list_item_path(item), method: :delete, variant: :ghost) { "Remove" }
      end
    end
end
