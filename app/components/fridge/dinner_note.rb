# A note that decides tonight's dinner; tap it to roll again (dinner_controller.js).
class Components::Fridge::DinnerNote < Components::Base
  include Components::Fridge
  def initialize(names:)
    @names = names
  end

  def view_template
    button(type: :button, data: { controller: "dinner", dinner_names_value: @names.to_json, action: "dinner#roll" }, aria: { label: "Tonight's dinner. Tap to pick another." },
           class: "magnet-in absolute left-(--x) top-(--y) z-[2] flex w-[44cqw] rotate-2 flex-col bg-brand-2/20 px-[3cqw] pb-[3cqw] pt-[5cqw] text-left text-foreground #{NOTE_SHADOW} md:left-(--mx) md:top-(--my) md:w-[20cqw] md:px-[1.6cqw] md:pb-[1.4cqw] md:pt-[2.6cqw]",
           style: "--x: 52%; --y: 62%; --mx: 72%; --my: 9%; --d: 0.8s") do
      span(class: "absolute left-1/2 top-[1.4cqw] size-[3.6cqw] -translate-x-1/2 rounded-full bg-brand-2 shadow-md md:top-[0.6cqw] md:size-[1.6cqw]", aria_hidden: "true")
      span(class: "mb-[1cqw] text-[3.4cqw] font-semibold uppercase tracking-widest text-muted-foreground md:text-[1.1cqw]") { "tonight" }
      span(data: { dinner_target: "name" }, aria: { live: "polite" },
           class: "min-h-[3.6em] #{HAND} text-[6.4cqw] font-bold leading-[1.1] text-balance transition duration-200 md:text-[2.6cqw]") { @names.first }
      span(class: "mt-[1.5cqw] #{HAND} text-[4cqw] text-primary md:text-[1.6cqw]") { "↻ tap to decide again" }
    end
  end
end
