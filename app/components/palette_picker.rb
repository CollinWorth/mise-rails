# The profile's color palette chooser: one tile per palette, drawn in that palette's own colors.
# Choosing one previews it at once (palette_controller.js) and saves it (autosubmit).
class Components::PalettePicker < Components::Base
  def initialize(selected:)
    @selected = selected
  end

  def view_template
    ActionForm(action: profile_path, method: :patch, data: { controller: "autosubmit palette", action: "change->palette#preview change->autosubmit#queue" }) do
      fieldset(class: "grid grid-cols-2 gap-3 sm:grid-cols-3") do
        legend(class: "sr-only") { "Color palette" }
        Palette::NAMES.each { |key, name| option(key, name) }
      end
    end
  end

  private
    def option(key, name)
      label(class: "cursor-pointer") do
        input(type: :radio, name: "user[palette]", value: key, checked: key == @selected, class: "peer sr-only")
        div(data: { palette: key }, class: "flex flex-col gap-2 rounded-xl border-2 bg-background p-3 text-foreground transition peer-checked:border-primary peer-focus-visible:ring-2 peer-focus-visible:ring-ring") do
          div(class: "flex gap-1.5") do
            span(class: "size-5 rounded-full bg-primary")
            span(class: "size-5 rounded-full border bg-secondary")
            span(class: "size-5 rounded-full bg-foreground")
            span(class: "size-5 rounded-full border bg-muted")
          end
          span(class: "text-sm font-medium") { name }
        end
      end
    end
end
