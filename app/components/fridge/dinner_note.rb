# A note that decides tonight's dinner; tap it to roll again (dinner_controller.js).
class Components::Fridge::DinnerNote < Components::Base
  include Components::Fridge

  def initialize(names:)
    @names = names
  end

  def view_template
    button(type: :button, data: { controller: "dinner", dinner_names_value: @names.to_json, action: "dinner#roll" }, aria: { label: "Tonight's dinner. Tap to pick another." },
           class: "magnet-in absolute left-(--x) top-(--y) z-[2] flex w-[42cqw] rotate-2 flex-col bg-brand-2/20 px-[3cqw] pb-[3cqw] pt-[5cqw] text-left text-foreground #{NOTE_SHADOW}",
           style: "--x: 50%; --y: 97cqw; --d: 0.8s") do
      span(class: "absolute left-1/2 top-[1.4cqw] size-[3.6cqw] -translate-x-1/2 rounded-full bg-brand-2 shadow-md", aria_hidden: "true")
      span(class: "mb-[1cqw] text-[3.4cqw] font-semibold uppercase tracking-widest text-muted-foreground") { "tonight" }
      span(data: { dinner_target: "name" }, aria: { live: "polite" },
           class: "min-h-[3.6em] #{HAND} text-[6.4cqw] font-bold leading-[1.1] text-balance transition duration-200") { @names.first }
      span(class: "mt-[1.5cqw] #{HAND} text-[4cqw] text-primary") { "↻ tap to decide again" }
    end
  end
end
