# The calendar: one week at a time, a day strip to jump around on a phone, and the week's meals as photo tiles.
class Views::PlannedMeals::Index < Views::Base
  def initialize(week_start:, meals:)
    @week_start = week_start
    @meals = meals
  end

  def view_template
    PageHeader(title: range) do
      Link(href: planned_meals_path(date: @week_start - 7), variant: :outline, icon: true, aria: { label: "Previous week" }) { Icon(:chevron_left, class: "size-4") }
      Link(href: planned_meals_path(date: @week_start + 7), variant: :outline, icon: true, aria: { label: "Next week" }) { Icon(:chevron_right, class: "size-4") }
      Link(href: planned_meals_path(date: Date.current), variant: :outline) { "Today" } unless current_week?
    end
    Row(justify: :between) do
      Text(class: "text-muted-foreground") { summary }
      SheetLink(href: new_grocery_list_meal_plan_path(date: @week_start), variant: :primary) { "Add to grocery list" } if planned.positive?
    end
    DayStrip(week_start: @week_start, planned_dates: @meals.keys)
    Grid(columns: :week) { (0..6).each { |offset| PlannerDay(date: @week_start + offset, meals: @meals.fetch(@week_start + offset, [])) } }
  end

  private
    def planned = @meals.values.sum(&:size)
    def current_week? = @week_start == Date.current.beginning_of_week

    # "Nov 9 – 15", or "Nov 30 – Dec 6" when the week crosses a month.
    def range
      last = @week_start + 6
      "#{@week_start.strftime('%b %-d')} – #{last.month == @week_start.month ? last.day : last.strftime('%b %-d')}"
    end

    def summary
      return "Nothing planned yet. Add a recipe to any day." if planned.zero?

      open = 7 - @meals.size
      "#{planned} #{'meal'.pluralize(planned)} planned · #{open} #{'day'.pluralize(open)} open"
    end
end
