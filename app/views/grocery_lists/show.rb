class Views::GroceryLists::Show < Views::Base
  def initialize(list:)
    @list = list
  end

  def view_template
    Narrow do
      PageHeader(title: "Grocery list") do
        Link(href: pantry_items_path, variant: :outline) { "Pantry" }
        Link(href: planned_meals_path, variant: :outline) { "Plan meals" }
        more_menu if @list.items.any?
      end
      add_form
      items = @list.items.includes(:sources).to_a
      if items.none?
        EmptyState(title: "Your list is empty", text: "Add something above, or plan a few meals and shop for the week.", icon: :basket)
      else
        to_get, checked = items.partition { |item| !item.checked? }
        aisles(to_get)
        checked_section(checked) if checked.any?
      end
    end
  end

  private
    # Emptying the list is tucked away here, and still asks for confirmation in a sheet.
    def more_menu
      Menu(label: "More list actions", trigger: -> { span(class: "flex size-10 items-center justify-center rounded-full border") { Icon(:ellipsis) } }) do
        MenuItem(href: new_grocery_list_clearance_path, icon: :trash, data: { turbo_frame: "modal" }) { "Clear list…" }
      end
    end

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
          CardHeader { CardTitle(class: "text-brand-2") { config["label"] } }
          CardContent { Stack(gap: :sm) { aisle_items.each { |item| GroceryItemRow(item:) } } }
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
        CardContent { Stack(gap: :sm) { items.each { |item| GroceryItemRow(item:) } } }
      end
    end
end
