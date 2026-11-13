# Adds a week of planned meals to the grocery list, after a review of what's included.
class GroceryLists::MealPlansController < ApplicationController
  include ShoppingTripScoped

  def new
    render_sheet(fallback: planned_meals_path(date: trip.week_start)) { Views::GroceryLists::MealPlans::New.new(trip:) }
  end

  # ingredient_keys is what was ticked in the review; without it (no review), everything but pantry items is added.
  def create
    result = Current.user.grocery_list.add_meals(trip.selected_meals, only: params[:ingredient_keys]&.compact_blank)
    redirect_to grocery_list_path, notice: result.summary, status: :see_other
  end
end
