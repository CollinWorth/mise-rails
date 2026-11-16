# The calendar's Week | Month switch, keeping you on the same day.
class Components::PlannerViews < Components::Base
  def initialize(date:, active:)
    @date = date
    @active = active
  end

  def view_template
    Segmented do |views|
      views.option("Week", planned_meals_path(date: @date), active: @active == :week)
      views.option("Month", planned_meals_path(date: @date, view: "month"), active: @active == :month)
    end
  end
end
