# One magnet word. Drag it (pointer or finger) or move it with the arrow keys; magnets_controller.js does the moving and snaps
# a word onto the end of another so a sentence lines up.
class Components::Fridge::Word < Components::Base
  include Components::Fridge

  # Written out in full so Tailwind sees every class; sizes scale with the door (cqw = % of its width).
  STYLES = {
    plain: "bg-background text-foreground text-[4.4cqw]",
    primary: "bg-primary text-primary-foreground text-[4.4cqw]",
    secondary: "bg-brand-2 text-primary-foreground text-[4.4cqw]",
    tertiary: "bg-brand-3 text-primary-foreground text-[4.4cqw]",
    big: "bg-background text-foreground text-[10cqw]",
    hero: "bg-primary text-primary-foreground text-[11cqw]"
  }.freeze

  def initialize(text, x, y, tilt, style, delay: 0)
    @text = text
    @x = x
    @y = y
    @tilt = tilt
    @style = style
    @delay = delay
  end

  def view_template
    div(role: "button", tabindex: 0, aria: { roledescription: "magnet", label: "#{@text} magnet. Drag it, or use the arrow keys." },
        data: { magnets_target: "magnet", action: "pointerdown->magnets#down pointermove->magnets#move pointerup->magnets#up pointercancel->magnets#up keydown->magnets#key" },
        style: "--x: #{@x}%; --y: #{@y}cqw; --r: #{@tilt}deg; --d: #{(@delay * 0.05).round(2)}s",
        class: [ "magnet-in absolute left-(--x) top-(--y) z-[1] cursor-grab touch-none whitespace-nowrap rounded-[0.35em] border px-[0.5em] py-[0.12em] font-semibold leading-tight tracking-tight",
                 "rotate-(--r) #{MAGNET_SHADOW} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring", STYLES.fetch(@style) ]) { @text }
  end
end
