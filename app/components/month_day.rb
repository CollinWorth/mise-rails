# One day in the month grid, a link to that day in the week view. A phone has room for a date and a dot per meal; from lg up the
# cell has the date and the names of what's planned.
class Components::MonthDay < Components::Base
  def initialize(date:, meals:, in_month:)
    @date = date
    @meals = meals
    @in_month = in_month
  end

  def view_template
    a(href: planned_meals_path(date: @date), aria: { label: label },
      class: [ "flex min-h-14 flex-col items-center gap-1 border-b border-r p-1 hover:bg-muted/50 lg:min-h-28 lg:items-stretch lg:p-2", (@in_month ? "" : "bg-muted/30 text-muted-foreground") ]) do
      span(class: [ "flex size-7 items-center justify-center rounded-full text-sm font-semibold lg:self-start", (today? ? "bg-primary text-primary-foreground" : "") ]) { @date.day.to_s }
      dots
      names
    end
  end

  private
    def today? = @date == Date.current

    def label
      count = @meals.size
      "#{@date.strftime('%A, %B %-d')}, #{count.zero? ? 'nothing planned' : "#{count} planned"}"
    end

    def dots
      div(class: "flex flex-wrap justify-center gap-0.5 lg:hidden") do
        @meals.first(4).each { |meal| span(class: [ "size-1.5 rounded-full", (meal.note? ? "bg-brand-3" : "bg-brand-2") ]) }
      end
    end

    def names
      div(class: "hidden min-w-0 flex-col gap-1 lg:flex") do
        @meals.each do |meal|
          span(class: [ "break-words rounded px-1.5 py-0.5 text-xs font-medium", (meal.note? ? "bg-brand-3/20" : "bg-brand-2/15") ]) { meal.name }
        end
      end
    end
end
