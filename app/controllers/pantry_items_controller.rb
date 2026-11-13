class PantryItemsController < ApplicationController
  def index
    items = Current.user.pantry_items.order(:normalized_name)
    suggestions = PantryItem::SUGGESTIONS.reject { |name| items.any? { |item| item.normalized_name == IngredientName.normalize(name) } }
    render Views::PantryItems::Index.new(items:, suggestions:)
  end

  def create
    item = Current.user.pantry_items.build(params.expect(pantry_item: :name))
    item.save
    redirect_back_or_to pantry_items_path, alert: (item.errors.full_messages.to_sentence if item.errors.any?), status: :see_other
  end

  def destroy
    Current.user.pantry_items.find(params[:id]).destroy
    redirect_back_or_to pantry_items_path, status: :see_other
  end
end
