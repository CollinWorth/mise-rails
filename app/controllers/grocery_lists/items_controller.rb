class GroceryLists::ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  def create
    item = Current.user.grocery_list.items.build(params.expect(item: %i[name quantity unit category]).compact_blank)
    item.save
    redirect_to grocery_list_path, alert: (item.errors.full_messages.to_sentence if item.errors.any?), status: :see_other
  end

  def show
    render_sheet(fallback: grocery_list_path) { Views::GroceryLists::Items::Show.new(item: @item) }
  end

  def edit
    render_sheet(fallback: grocery_list_path) { Views::GroceryLists::Items::Edit.new(item: @item) }
  end

  def update
    @item.update!(params.expect(item: %i[name quantity unit category checked]))
    redirect_to grocery_list_path, status: :see_other
  end

  def destroy
    @item.destroy
    redirect_to grocery_list_path, status: :see_other
  end

  private
    def set_item
      @item = Current.user.grocery_list.items.find(params[:id])
    end
end
