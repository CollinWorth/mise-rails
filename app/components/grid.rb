# Responsive card grid: one column on phones, `columns` on desktop. `:week` is the planner's seven days (a single column on phones). `:aside` (narrow + wide) and `:hero` (picture + details) are page layouts.
class Components::Grid < Components::Base
  COLUMNS = { 2 => "sm:grid-cols-2", 3 => "sm:grid-cols-2 lg:grid-cols-3", 4 => "sm:grid-cols-2 lg:grid-cols-4", week: "lg:grid-cols-7 lg:gap-3",
                aside: "items-start lg:grid-cols-[minmax(0,1fr)_minmax(0,2fr)] lg:gap-10", hero: "items-start lg:grid-cols-[minmax(0,2fr)_minmax(0,3fr)] lg:gap-10" }.freeze

  def initialize(columns: 3, **attrs)
    @attrs = attrs
    @columns = columns
  end

  def view_template(&) = div(class: [ "grid gap-4 grid-cols-1", COLUMNS.fetch(@columns) ], **@attrs, &)
end
