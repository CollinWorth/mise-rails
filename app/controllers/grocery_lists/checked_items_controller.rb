class GroceryLists::CheckedItemsController < ApplicationController
  def destroy
    Current.user.grocery_list.items.where(checked: true).destroy_all
    redirect_to grocery_list_path, status: :see_other
  end
end
