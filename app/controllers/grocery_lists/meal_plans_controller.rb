# Adds the ingredients of a week of planned meals to the grocery list.
class GroceryLists::MealPlansController < ApplicationController
  def create
    week = Date.parse(params.expect(:date)).beginning_of_week
    count = Current.user.grocery_list.add_meals(Current.user.planned_meals.between(week..week + 6))
    redirect_to grocery_list_path, notice: "#{count} items added from this week's meals.", status: :see_other
  end
end
