# The in-place edit form that replaces a GroceryItemRow on a desktop. Cancel loads the row back from the list page.
class Components::GroceryItemEditRow < Components::Base
  def initialize(item:)
    @item = item
  end

  def view_template
    turbo_frame(id: "item_#{@item.id}") do
      div(class: "flex flex-col gap-2 rounded-lg border bg-muted/30 p-3") do
        ActionForm(action: grocery_list_item_path(@item), method: :patch, top: true) do
          Stack(gap: :sm) do
            Input(name: "item[name]", value: @item.name, required: true, autofocus: true, aria: { label: "Item" })
            Row(gap: :sm) do
              Input(name: "item[quantity]", value: @item.quantity, placeholder: "Qty", class: "w-20", aria: { label: "Quantity" })
              Input(name: "item[unit]", value: @item.unit, placeholder: "Unit", class: "w-24", aria: { label: "Unit" })
              Button(type: :submit) { "Save" }
              Link(href: grocery_list_path, variant: :ghost) { "Cancel" }
            end
          end
        end
        ButtonTo(action: grocery_list_item_path(@item), method: :delete, variant: :ghost, top: true, button_class: "h-auto px-0 py-0 text-xs text-destructive") { "Delete item" }
      end
    end
  end
end
