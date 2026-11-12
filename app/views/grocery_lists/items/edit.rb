class Views::GroceryLists::Items::Edit < Views::Base
  def initialize(item:)
    @item = item
  end

  def view_template
    Sheet(title: "Edit item") do
      Stack do
        ActionForm(action: grocery_list_item_path(@item), method: :patch, data: { turbo_frame: "_top" }) do
          Stack do
            Field(label: "Item", name: "item[name]", id: "item_name", value: @item.name, required: true)
            Row do
              Field(label: "Quantity", name: "item[quantity]", id: "item_quantity", value: @item.quantity, class: "w-28")
              Field(label: "Unit", name: "item[unit]", id: "item_unit", value: @item.unit, class: "w-28")
            end
            Button(type: :submit) { "Save" }
          end
        end
        ButtonTo(action: grocery_list_item_path(@item), method: :delete, variant: :destructive, size: :md, data: { turbo_frame: "_top" }) { "Delete item" }
      end
    end
  end
end
