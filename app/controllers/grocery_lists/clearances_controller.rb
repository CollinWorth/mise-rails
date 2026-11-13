# Emptying the whole grocery list: a confirmation sheet first, then the delete.
class GroceryLists::ClearancesController < ApplicationController
  def new
    render_sheet(fallback: grocery_list_path) { Views::GroceryLists::Clearances::New.new(count: items.count, checked: items.where(checked: true).count) }
  end

  def create
    count = items.destroy_all.size
    redirect_to grocery_list_path, notice: "Cleared #{count} #{'item'.pluralize(count)}.", status: :see_other
  end

  private
    def items = Current.user.grocery_list.items
end
