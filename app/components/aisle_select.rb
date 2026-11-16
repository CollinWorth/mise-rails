# Choose the aisle an item is listed under (it starts as the one its name suggests).
class Components::AisleSelect < Components::Base
  def initialize(item:, id: "item_category")
    @item = item
    @id = id
  end

  def view_template
    FormField do
      FormFieldLabel(for: @id) { "Aisle" }
      select(id: @id, name: "item[category]", class: "w-full rounded-md border border-input bg-background px-3 py-2 text-sm") do
        GroceryItem::CATEGORIES.each do |key, config|
          option(value: key, selected: key == @item.category) { config["label"] }
        end
      end
    end
  end
end
