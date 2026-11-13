# A sticky note with a grocery list; tapping an item crosses it off (tick_controller.js).
class Components::Fridge::GroceryNote < Components::Base
  include Components::Fridge

  ITEMS = %w[lemons feta tomatoes rice].freeze

  def view_template
    div(data: { controller: "tick" }, aria: { label: "Grocery list" },
        class: "group magnet-in absolute left-(--x) top-(--y) z-[2] w-[42cqw] -rotate-2 bg-brand-3/25 px-[3cqw] pb-[3cqw] pt-[5cqw] text-foreground #{NOTE_SHADOW}",
        style: "--x: 4%; --y: 96cqw; --d: 0.7s") do
      span(class: "absolute left-1/2 top-[1.4cqw] size-[3.6cqw] -translate-x-1/2 rounded-full bg-primary shadow-md", aria_hidden: "true")
      div(class: "mb-[1.5cqw] #{HAND} text-[5.6cqw] font-bold leading-none") { "groceries" }
      ul(class: "flex flex-col") do
        ITEMS.each { |item| li { tick(item) } }
      end
      span(class: "pointer-events-none absolute -right-[2cqw] bottom-[2cqw] hidden rotate-12 rounded-[0.5em] border-2 border-primary px-[1.4cqw] #{HAND} text-[4cqw] font-bold text-primary group-data-[done]:block") { "all set!" }
    end
  end

  private
    def tick(item)
      button(type: :button, aria: { pressed: "false" }, data: { action: "tick#toggle", tick_target: "item" },
             class: "w-full text-left #{HAND} text-[5cqw] leading-snug decoration-2 aria-pressed:line-through aria-pressed:opacity-50") { "· #{item}" }
    end
end
