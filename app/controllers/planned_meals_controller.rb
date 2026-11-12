class PlannedMealsController < ApplicationController
  def index
    week_start = (requested_date || Date.current).beginning_of_week
    meals = Current.user.planned_meals.between(week_start..week_start + 6).includes(:recipe).order(:id)
    render Views::PlannedMeals::Index.new(week_start:, meals: meals.group_by(&:date), recipes: Current.user.recipes.order(:name))
  end

  def create
    meal = Current.user.planned_meals.build(params.expect(planned_meal: %i[recipe_id date multiplier]))
    meal.recipe = Current.user.recipes.find(meal.recipe_id)
    meal.save!
    redirect_back_or_to planned_meals_path(date: meal.date), status: :see_other
  end

  def destroy
    meal = Current.user.planned_meals.find(params[:id])
    meal.destroy
    redirect_back_or_to planned_meals_path(date: meal.date), status: :see_other
  end

  private
    def requested_date
      Date.iso8601(params[:date]) if params[:date].present?
    rescue Date::Error
      nil
    end
end
