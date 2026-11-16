# The month's days as a grid of weeks (Monday first), padded with the neighbouring months' days at either end.
class Components::MonthGrid < Components::Base
  def initialize(month_start:, meals:)
    @month_start = month_start
    @meals = meals
  end

  def view_template
    Card(class: "overflow-hidden") do
      div(class: "grid grid-cols-7 border-l border-t") do
        Date::ABBR_DAYNAMES.rotate(1).each { |day| div(class: "border-b border-r bg-muted/40 py-1 text-center text-xs font-semibold uppercase tracking-wide text-muted-foreground") { day } }
        days.each { |date| MonthDay(date:, meals: @meals.fetch(date, []), in_month: date.month == @month_start.month) }
      end
    end
  end

  private
    def days = (@month_start.beginning_of_week..@month_start.end_of_month.end_of_week).to_a
end
