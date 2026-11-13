# Numbered instructions, one per line. Tap a step to tick it off (its number turns into a check); see checklist_controller.js.
class Components::Steps < Components::Base
  def initialize(steps:)
    @steps = steps
  end

  def view_template
    ol(class: "flex flex-col gap-5") do
      @steps.each_with_index do |step, index|
        li do
          label(class: "group flex cursor-pointer gap-4") do
            input(type: :checkbox, value: "s#{index}", class: "peer sr-only", data: { checklist_target: "item", action: "change->checklist#save" })
            span(class: "flex size-8 shrink-0 items-center justify-center rounded-full bg-primary text-sm font-semibold text-primary-foreground transition group-has-[:checked]:bg-muted group-has-[:checked]:text-muted-foreground peer-focus-visible:ring-2 peer-focus-visible:ring-ring") do
              span(class: "group-has-[:checked]:hidden") { index + 1 }
              Icon(:check, class: "hidden size-4 group-has-[:checked]:block")
            end
            p(class: "pt-1 leading-relaxed transition group-has-[:checked]:text-muted-foreground group-has-[:checked]:line-through") { step }
          end
        end
      end
    end
  end
end
