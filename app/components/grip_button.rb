# The drag handle of a reorderable row. Dragging is wired by the reorder controller; the arrow keys, when this has focus,
# call moveUp / moveDown on `controller` (a Stimulus controller name such as "steps").
class Components::GripButton < Components::Base
  def initialize(label:, controller:, **attrs)
    @label = label
    @controller = controller
    @attrs = attrs
  end

  def view_template
    Button(type: :button, variant: :ghost, size: :sm, class: [ "size-8 shrink-0 cursor-grab touch-none p-0 text-muted-foreground", @attrs.delete(:class) ],
           aria: { label: "#{@label}, or press the up and down arrows" },
           data: { handle: true, action: "keydown.up->#{@controller}#moveUp keydown.down->#{@controller}#moveDown" }, **@attrs) { Icon(:grip, class: "size-4") }
  end
end
