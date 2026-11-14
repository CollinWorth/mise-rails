class PlannedMealsController < ApplicationController
  def index
    week_start = (date_param || Date.current).beginning_of_week
    meals = Current.user.planned_meals.between(week_start..week_start + 6).includes(:recipe).order(:id)
    render Views::PlannedMeals::Index.new(week_start:, meals: meals.group_by(&:date))
  end

  # The add-a-meal sheet, loaded into the layout's `modal` Turbo Frame.
  def new
    render_sheet(fallback: planned_meals_path(date: params[:date])) { new_meal_sheet }
  end

  # A recipe (`recipe_id`) or a note (`title`, with no recipe: "Leftovers", "Eating out").
  def create
    meal = Current.user.planned_meals.build(params.expect(planned_meal: %i[recipe_id title date multiplier]))
    if meal.recipe_id.present?
      meal.recipe = Recipe.visible_to(Current.user).find(meal.recipe_id)
      meal.title = nil
    end
    meal.save!
    redirect_back_or_to planned_meals_path(date: meal.date), notice: "Added #{meal.note? ? "“#{meal.title}”" : meal.recipe.name} to #{meal.date.strftime('%A')}.", status: :see_other
  end

  def destroy
    meal = Current.user.planned_meals.find(params[:id])
    meal.destroy
    redirect_back_or_to planned_meals_path(date: meal.date), status: :see_other
  end

  private
    # With a recipe, pick a day for it; otherwise pick a recipe for the day.
    def new_meal_sheet
      if params[:recipe_id].present?
        Views::PlannedMeals::New.new(recipe: Recipe.visible_to(Current.user).find(params[:recipe_id]))
      else
        recipes = Current.user.recipes.search(params[:q]).order(:name).limit(30)
        Views::PlannedMeals::New.new(date: date_param || Date.current, recipes:, query: params[:q].to_s)
      end
    end
end
