# Round magnets in each theme's colors: tap one and the whole page, fridge included, changes to that theme
# (landing_palette_controller.js; nothing is saved).
class Components::Fridge::ColorMagnets < Components::Base
  def view_template
    div(data: { controller: "landing-palette" }, class: "flex flex-col items-center gap-3 md:items-start") do
      Text(as: "span", size: "2", class: "text-muted-foreground") { "Pick the fridge's color" }
      div(class: "grid grid-cols-4 gap-4 sm:flex sm:flex-wrap sm:gap-3") do
        Palette::LIGHT.each { |key, name| magnet(key, name, mode: "light") }
        Palette::DARK.each { |key, name| magnet(key, name, mode: "dark") }
      end
    end
  end

  private
    # `data-palette` gives the button that theme's colors, so it can show them whatever theme the page is in.
    def magnet(key, name, mode:)
      button(type: :button, aria: { pressed: "false", label: name }, title: name,
             data: { palette: key, mode:, landing_palette_target: "tile", action: "landing-palette#choose" },
             class: "size-9 rounded-full border-[3px] border-card bg-gradient-to-br from-primary from-50% to-brand-2 to-50% shadow-md ring-1 ring-foreground/10 transition hover:scale-110 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring aria-pressed:ring-2 aria-pressed:ring-foreground")
    end
end
