# An ingredient you can tick off while cooking; its state is kept per recipe by checklist_controller.js.
class Components::ChecklistItem < Components::Base
  def initialize(value:)
    @value = value
  end

  def view_template(&text)
    label(class: "flex cursor-pointer items-start gap-3 py-0.5 has-[:checked]:text-muted-foreground has-[:checked]:line-through") do
      Checkbox(value: @value, class: "mt-1.5", data: { checklist_target: "item", action: "change->checklist#save" })
      span(&text)
    end
  end
end
