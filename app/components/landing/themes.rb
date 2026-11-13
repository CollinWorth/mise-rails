# "Make it yours": one tile per theme; choosing one restyles the page (landing_palette_controller.js). Nothing is saved.
class Components::Landing::Themes < Components::Base
  def view_template
    section(class: "mx-auto max-w-6xl px-4 py-16 lg:py-24", data: { controller: "landing-palette" }) do
      SectionHeading(title: "Make it yours.", subtitle: "Light, dark, or whatever your phone is doing. Pick colors you like. Try one now, the whole page changes.")
      Stack(gap: :lg, data: { controller: "reveal" }) do
        row("Light", Palette::LIGHT, mode: "light")
        row("Dark", Palette::DARK, mode: "dark")
      end
    end
  end

  private
    def row(label, themes, mode:)
      Stack(gap: :sm) do
        Text(as: "span", size: "2", weight: "medium", class: "text-muted-foreground") { label }
        div(class: "grid grid-cols-2 gap-3 sm:grid-cols-4") { themes.each { |key, name| tile(key, name, mode:) } }
      end
    end

    def tile(key, name, mode:)
      button(type: :button, data: { palette: key, mode:, landing_palette_target: "tile", action: "landing-palette#choose" }, aria: { pressed: "false" },
             class: "flex flex-col gap-2 rounded-2xl border-2 bg-background p-4 text-left text-foreground shadow-sm transition hover:-translate-y-0.5 hover:shadow-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring aria-pressed:border-primary") do
        Swatches()
        Text(as: "span", size: "2", weight: "medium") { name }
      end
    end
end
