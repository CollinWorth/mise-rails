class Views::GroceryLists::Show < Views::Base
  def initialize(list:)
    @list = list
  end

  def view_template
    PageHeader(title: "Grocery list") do
      Link(href: planned_meals_path, variant: :outline) { "Plan meals" }
    end
    add_form
    return Text { "Your list is empty." } if @list.items.none?

    to_get, checked = @list.items.partition { |item| !item.checked? }
    aisles(to_get)
    checked_section(checked) if checked.any?
  end

  private
    def add_form
      ActionForm(action: grocery_list_items_path) do
        Row(gap: :sm) do
          Input(name: "item[quantity]", placeholder: "Qty", class: "w-16 shrink-0")
          Input(name: "item[unit]", placeholder: "Unit", class: "w-20 shrink-0")
          Input(name: "item[name]", placeholder: "Add an item", class: "min-w-0 flex-1 basis-40", required: true)
          Button(type: :submit) { "Add" }
        end
      end
    end

    # Group by aisle in the order set in config/grocery_categories.yml
    def aisles(items)
      by_category = items.group_by(&:category)
      GroceryItem::CATEGORIES.each do |key, config|
        next unless (aisle_items = by_category[key])

        Card do
          CardHeader { CardTitle { config["label"] } }
          CardContent { Stack(gap: :sm) { aisle_items.each { |item| item_row(item) } } }
        end
      end
    end

    def checked_section(items)
      Card do
        CardHeader do
          Row(justify: :between) do
            CardTitle { "Checked (#{items.size})" }
            ButtonTo(action: grocery_list_checked_items_path, method: :delete, data: { turbo_confirm: "Remove all checked items?" }) { "Clear" }
          end
        end
        CardContent { Stack(gap: :sm) { items.each { |item| item_row(item) } } }
      end
    end

    # The box toggles checked; the name opens the edit sheet.
    def item_row(item)
      Row(gap: :sm) do
        ActionForm(action: grocery_list_item_path(item), method: :patch, class: "inline") do
          input(type: :hidden, name: "item[checked]", value: item.checked? ? "0" : "1")
          Button(type: :submit, variant: item.checked? ? :secondary : :outline, size: :md) { item.checked? ? "☑" : "☐" }
        end
        Link(href: edit_grocery_list_item_path(item), variant: :ghost, data: { turbo_frame: "modal" },
             class: [ "h-auto justify-start whitespace-normal px-2 py-2 text-left", ("line-through text-muted-foreground" if item.checked?) ]) do
          [ item.quantity, item.unit, item.name ].compact_blank.join(" ")
        end
      end
    end
end
