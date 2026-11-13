# The small ✕ at the end of an editable row. `action` is a Stimulus action such as "steps#remove".
class Components::RemoveButton < Components::Base
  def initialize(label:, action:, **attrs)
    @label = label
    @action = action
    @attrs = attrs
  end

  def view_template
    Button(type: :button, variant: :ghost, size: :sm, class: [ "size-8 shrink-0 p-0 text-muted-foreground", @attrs.delete(:class) ], aria: { label: @label },
           data: { action: @action }, **@attrs) { Icon(:x, class: "size-4") }
  end
end
