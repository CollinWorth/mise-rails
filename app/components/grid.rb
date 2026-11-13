# Responsive card grid: one column on phones, `columns` on desktop.
class Components::Grid < Components::Base
  COLUMNS = { 2 => "sm:grid-cols-2", 3 => "sm:grid-cols-2 lg:grid-cols-3", 4 => "sm:grid-cols-2 lg:grid-cols-4", 7 => "sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-7" }.freeze

  def initialize(columns: 3, **attrs)
    @attrs = attrs
    @columns = columns
  end

  def view_template(&) = div(class: [ "grid gap-4 grid-cols-1", COLUMNS.fetch(@columns) ], **@attrs, &)
end
