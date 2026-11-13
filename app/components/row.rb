# Horizontal flex container that wraps on small screens.
class Components::Row < Components::Base
  GAPS = Components::Stack::GAPS

  def initialize(gap: :md, justify: :start, **attrs)
    @attrs = attrs
    @gap = gap
    @justify = justify
  end

  def view_template(&)
    div(class: [ "flex flex-wrap items-center", GAPS.fetch(@gap), JUSTIFY.fetch(@justify), @attrs.delete(:class) ], **@attrs, &)
  end

  JUSTIFY = { start: "justify-start", center: "justify-center", between: "justify-between", end: "justify-end" }.freeze
end
