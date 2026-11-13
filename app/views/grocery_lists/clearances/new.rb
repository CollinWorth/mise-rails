# The "are you sure" sheet behind Clear list. Cancel comes first and the destructive button is spelled out with the item count.
class Views::GroceryLists::Clearances::New < Views::Base
  def initialize(count:, checked:)
    @count = count
    @checked = checked
  end

  def view_template
    Sheet(title: "Clear the grocery list?") do
      Stack do
        Text { "This removes all #{@count} #{'item'.pluralize(@count)} (#{@checked} checked, #{@count - @checked} still to get). It can't be undone." }
        ActionForm(action: grocery_list_clearance_path, top: true) do
          Row(gap: :sm, justify: :end) do
            Button(type: :button, variant: :outline, data: { action: "sheet#dismiss" }) { "Keep my list" }
            Button(type: :submit, variant: :destructive) { "Clear #{@count} #{'item'.pluralize(@count)}" }
          end
        end
      end
    end
  end
end
