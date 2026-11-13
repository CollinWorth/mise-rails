# Numbered instructions, one per line.
class Components::Steps < Components::Base
  def initialize(steps:)
    @steps = steps
  end

  def view_template
    ol(class: "flex flex-col gap-5") do
      @steps.each_with_index do |step, index|
        li(class: "flex gap-4") do
          span(class: "flex size-8 shrink-0 items-center justify-center rounded-full bg-primary text-sm font-semibold text-primary-foreground") { index + 1 }
          p(class: "pt-1 leading-relaxed") { step }
        end
      end
    end
  end
end
