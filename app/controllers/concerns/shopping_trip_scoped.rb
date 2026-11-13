# For the "shop for this week" review: builds the trip from the date and the meals picked in the form.
module ShoppingTripScoped
  extend ActiveSupport::Concern

  private
    # meal_ids is absent for the first view (all meals) and an array, possibly empty, once meals have been picked.
    def trip
      @trip ||= ShoppingTrip.new(user: Current.user, week_start: (date_param || Date.current).beginning_of_week,
                                 meal_ids: params[:meal_ids]&.compact_blank)
    end
end
