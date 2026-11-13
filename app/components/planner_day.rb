# One day of the planner: its date, the meals planned for it as photo tiles, and a way to add another. On a phone the date sits
# beside the meals; from lg up the seven days are columns with the date on top.
class Components::PlannerDay < Components::Base
  include Phlex::Rails::Helpers::URLFor

  def initialize(date:, meals:)
    @date = date
    @meals = meals
  end

  def view_template
    Card(id: "day-#{@date.iso8601}", class: [ "scroll-mt-40 lg:scroll-mt-4", (@date == Date.current ? "border-primary bg-primary/5" : ""), (@date < Date.current ? "opacity-70" : "") ],
         data: { controller: ("scroll-into-view" if today?) }) do
      div(class: "flex gap-3 p-3 lg:flex-col") do
        heading
        div(class: "flex min-w-0 flex-1 flex-col gap-2") do
          @meals.each { |meal| PlannedMealTile(meal:) }
          SheetLink(href: new_planned_meal_path(date: @date), variant: :ghost, size: :sm, class: "w-full justify-center border border-dashed text-muted-foreground",
                    aria: { label: "Add a recipe to #{@date.strftime('%A')}" }) { "+ Add" }
        end
      end
    end
  end

  private
    def today? = @date == Date.current

    def heading
      div(class: "flex w-11 shrink-0 flex-col items-center lg:w-auto lg:flex-row lg:items-baseline lg:gap-2") do
        Text(size: "1", weight: "semibold", class: "uppercase tracking-wide text-muted-foreground") { @date.strftime("%a") }
        span(class: [ "flex size-9 items-center justify-center rounded-full text-lg font-semibold lg:size-auto lg:text-xl", (today? ? "bg-primary text-primary-foreground lg:bg-transparent lg:text-primary" : "") ]) { @date.day.to_s }
        Tag(tone: :tertiary, class: "hidden lg:inline-flex") { "Today" } if today?
      end
    end
end
