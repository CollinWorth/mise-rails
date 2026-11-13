# "Always have" on a line of the review: adds it to the pantry, unticks it, and redraws the review in place.
class GroceryLists::MealPlans::PantryItemsController < ApplicationController
  include ShoppingTripScoped

  def create
    entry = trip.totals[params.expect(:pantry_key)] or raise ActiveRecord::RecordNotFound
    Current.user.pantry_items.find_or_create_by!(name: entry.name)
    ticked = params[:ingredient_keys]&.compact_blank
    @trip = nil # rebuilt so the new pantry item shows

    render turbo_stream: turbo_stream.replace("shop-ingredients", Components::ShoppingReview.new(trip:, ticked: ticked&.without(entry.key)))
  end
end
