# The numbered circle of a step (recipe page, editor, landing page). Give it a block to draw something other than the number inside.
class Components::NumberBadge < Components::Base
  def initialize(number: nil, **attrs)
    @number = number
    @attrs = attrs
  end

  def view_template(&content)
    span(class: [ "flex size-8 shrink-0 items-center justify-center rounded-full bg-brand-2 text-sm font-semibold text-brand-2-foreground", @attrs.delete(:class) ], **@attrs) do
      content ? yield : plain(@number.to_s)
    end
  end
end
