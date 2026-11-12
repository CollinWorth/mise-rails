class GroceryListsController < ApplicationController
  def show
    render Views::GroceryLists::Show.new(list: Current.user.grocery_list)
  end
end
