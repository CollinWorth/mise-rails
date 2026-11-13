# A button that opens a small floating menu (see menu_controller.js). `trigger` draws the button's face; the block holds the MenuItems.
class Components::Menu < Components::Base
  def initialize(label:, trigger:, align: :end)
    @label = label
    @trigger = trigger
    @align = align
  end

  def view_template
    div(class: "relative", data: { controller: "menu", action: "keydown.esc@window->menu#close click@window->menu#clickAway" }) do
      Button(type: :button, variant: :ghost, size: :sm, class: "h-auto rounded-full p-1", aria: { label: @label, haspopup: "menu", expanded: "false" }, data: { action: "menu#toggle", menu_target: "button" }) { @trigger.call }
      div(role: "menu", hidden: true, data: { menu_target: "panel", action: "click->menu#close" },
          class: [ "absolute z-50 mt-2 min-w-52 rounded-lg border bg-popover p-1 text-popover-foreground shadow-lg", (@align == :end ? "right-0" : "left-0") ]) { yield }
    end
  end
end
