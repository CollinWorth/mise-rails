# The week as seven small date chips (phones only): a dot marks days that have meals, and tapping one jumps to that day.
class Components::DayStrip < Components::Base
  def initialize(week_start:, planned_dates:)
    @week_start = week_start
    @planned_dates = planned_dates
  end

  def view_template
    nav(class: "sticky top-[calc(env(safe-area-inset-top)+3.5rem)] z-10 -mx-4 grid grid-cols-7 border-b bg-background/90 px-2 py-2 backdrop-blur lg:hidden", aria: { label: "Days of the week" }, data: { controller: "day-strip" }) do
      (0..6).each { |offset| chip(@week_start + offset) }
    end
  end

  private
    def chip(date)
      today = date == Date.current
      a(href: "#day-#{date.iso8601}", class: "flex flex-col items-center gap-0.5 rounded-lg py-1 text-center", aria: { label: date.strftime("%A, %B %-d") }, data: { action: "day-strip#jump" }) do
        Text(size: "1", class: "uppercase text-muted-foreground") { date.strftime("%a")[0] }
        span(class: [ "flex size-8 items-center justify-center rounded-full text-sm font-semibold", (today ? "bg-primary text-primary-foreground" : "") ]) { date.day.to_s }
        span(class: [ "size-1.5 rounded-full", (@planned_dates.include?(date) ? "bg-brand-2" : "bg-transparent") ])
      end
    end
end
