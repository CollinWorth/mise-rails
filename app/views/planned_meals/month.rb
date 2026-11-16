# The calendar a month at a time: a grid of days, each a link to its week.
class Views::PlannedMeals::Month < Views::Base
  def initialize(month_start:, meals:)
    @month_start = month_start
    @meals = meals
  end

  def view_template
    PageHeader(title: @month_start.strftime("%B %Y")) do
      Link(href: planned_meals_path(date: @month_start << 1, view: "month"), variant: :outline, icon: true, aria: { label: "Previous month" }) { Icon(:chevron_left, class: "size-4") }
      Link(href: planned_meals_path(date: @month_start >> 1, view: "month"), variant: :outline, icon: true, aria: { label: "Next month" }) { Icon(:chevron_right, class: "size-4") }
      Link(href: planned_meals_path(date: Date.current, view: "month"), variant: :outline) { "Today" } unless current_month?
    end
    PlannerViews(date: @month_start, active: :month)
    Text(class: "text-muted-foreground") { summary }
    MonthGrid(month_start: @month_start, meals: @meals)
  end

  private
    def current_month? = @month_start == Date.current.beginning_of_month

    def summary
      planned = @meals.values.sum(&:size)
      planned.zero? ? "Nothing planned this month." : "#{planned} #{'meal'.pluralize(planned)} planned"
    end
end
