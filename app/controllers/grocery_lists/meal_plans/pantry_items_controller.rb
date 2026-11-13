# "Add to pantry" and "Remove from pantry" on a line of the review: change the pantry and redraw the review in place.
class GroceryLists::MealPlans::PantryItemsController < ApplicationController
  include ShoppingTripScoped

  # Adds it to the pantry and unticks it (every unit of it, since the pantry matches the ingredient, not the amount).
  def create
    entry = trip.totals[params.expect(:pantry_key)] or raise ActiveRecord::RecordNotFound
    Current.user.pantry_items.find_or_create_by!(name: entry.name)

    redraw(ticked: ticked_keys&.-(keys_for(entry)))
  end

  # Takes it out of the pantry; it then needs buying, so it is ticked again.
  def destroy
    entry = trip.totals[params[:id]] or raise ActiveRecord::RecordNotFound
    Current.user.pantry_items.where(normalized_name: entry.name_key).destroy_all

    redraw(ticked: ticked_keys&.|(keys_for(entry)))
  end

  private
    def ticked_keys = params[:ingredient_keys]&.compact_blank
    def keys_for(entry) = trip.totals.select { |other| other.name_key == entry.name_key }.map(&:key)

    def redraw(ticked:)
      @trip = nil # rebuilt so the pantry change shows
      render turbo_stream: turbo_stream.replace("shop-ingredients", Components::ShoppingReview.new(trip:, ticked:))
    end
end
