# The instructions editor: one auto-growing box per step, numbered, in the order they will be cooked. Return starts the
# next step, Backspace at the start of one joins it to the step above, pasting several lines makes several steps, and
# the grip drags a step (or moves it with the arrow keys). The steps are stored as the recipe's `instructions`, one per
# line, which a hidden field keeps up to date (see steps_controller.js).
class Components::StepsEditor < Components::Base
  def initialize(recipe:)
    @recipe = recipe
  end

  def view_template
    Stack(gap: :sm, data: { controller: "steps", action: "resize@window->steps#growAll" }) do
      Heading(level: 3) { "Instructions" }
      input(type: :hidden, name: "recipe[instructions]", value: @recipe.steps.join("\n"), data: { steps_target: "output" })
      ol(class: "flex flex-col gap-2", data: { steps_target: "list", controller: "reorder", action: "reorder:end->steps#sync" }) do
        (@recipe.steps.presence || [ "" ]).each_with_index { |step, index| row(step, index + 1) }
      end
      template(data: { steps_target: "template" }) { row("", "") }
      Button(type: :button, variant: :secondary, size: :sm, class: "self-start", data: { action: "steps#add" }) { "Add step" }
    end
  end

  private
    def row(text, number)
      li(class: "flex items-start gap-2", data: { steps_target: "item", reorder_item: true }) do
        grip
        span(class: "mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-full bg-brand-2 text-sm font-semibold text-brand-2-foreground", data: { steps_target: "number" }) { number }
        Textarea(rows: 1, placeholder: "Describe this step", aria: { label: "Step" }, class: "min-h-0 min-w-0 flex-1 resize-none overflow-hidden py-2 leading-snug",
                 data: { steps_target: "text", action: "input->steps#input keydown.enter->steps#enter keydown->steps#backspace paste->steps#paste" }) { text }
        Button(type: :button, variant: :ghost, size: :sm, class: "mt-0.5 size-8 shrink-0 p-0 text-muted-foreground", aria: { label: "Remove step" }, data: { action: "steps#remove" }) { Icon(:x, class: "size-4") }
      end
    end

    def grip
      Button(type: :button, variant: :ghost, size: :sm, class: "mt-0.5 size-8 shrink-0 cursor-grab touch-none p-0 text-muted-foreground", aria: { label: "Move step, or press the up and down arrows" },
             data: { handle: true, action: "keydown.up->steps#moveUp keydown.down->steps#moveDown" }) { Icon(:grip, class: "size-4") }
    end
end
