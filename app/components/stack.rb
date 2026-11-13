# Vertical flex container. RubyUI has no layout primitives, so views use these
# instead of raw divs.
class Components::Stack < Components::Base
  GAPS = { sm: "gap-2", md: "gap-4", lg: "gap-8" }.freeze

  def initialize(gap: :md, **attrs)
    @attrs = attrs
    @gap = gap
  end

  def view_template(&) = div(class: [ "flex flex-col", GAPS.fetch(@gap), @attrs.delete(:class) ], **@attrs, &)
end
