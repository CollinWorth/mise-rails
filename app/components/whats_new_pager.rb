# Announcement cards, one at a time with Back / Next. Without JavaScript they all show as a list. Opening it tells the
# server everything has been read (see the whats-new controller), so it never comes back however it is closed.
class Components::WhatsNewPager < Components::Base
  def initialize(entries:, seen_url:)
    @entries = entries
    @seen_url = seen_url
  end

  def view_template
    div(data: { controller: "whats-new", whats_new_seen_url_value: @seen_url }, class: "flex flex-col gap-6") do
      @entries.each { |entry| card(entry) }
      controls
    end
  end

  private
    def card(entry)
      div(data: { whats_new_target: "card" }, class: "flex flex-col items-start gap-3") do
        Tag(tone: :primary) { entry.date.strftime("%b %-d") }
        Heading(level: 2) { entry.title }
        Text { entry.body }
        TextLink(href: entry.path, data: { turbo_frame: "_top" }, class: "font-medium text-primary") { "Try it" } if entry.path
      end
    end

    def controls
      div(data: { whats_new_target: "controls" }, hidden: true, class: "flex items-center justify-between gap-2") do
        Button(type: :button, variant: :ghost, data: { whats_new_target: "back", action: "whats-new#back" }) { "Back" }
        span(data: { whats_new_target: "count" }, aria: { live: "polite" }, class: "text-sm text-muted-foreground")
        Button(type: :button, data: { whats_new_target: "next", action: "whats-new#next" }) { "Next" }
        Button(type: :button, data: { whats_new_target: "done", action: "sheet#dismiss" }) { "Got it" }
      end
    end
end
