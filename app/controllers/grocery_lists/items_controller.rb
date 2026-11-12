class GroceryLists::ItemsController < ApplicationController
  def create
    item = Current.user.grocery_list.items.build(params.expect(item: %i[name quantity unit category]).compact_blank)
    item.save
    redirect_to grocery_list_path, alert: (item.errors.full_messages.to_sentence if item.errors.any?), status: :see_other
  end

  def update
    Current.user.grocery_list.items.find(params[:id]).update(params.expect(item: %i[name quantity unit category checked]))
    redirect_to grocery_list_path, status: :see_other
  end

  def destroy
    Current.user.grocery_list.items.find(params[:id]).destroy
    redirect_to grocery_list_path, status: :see_other
  end
end
