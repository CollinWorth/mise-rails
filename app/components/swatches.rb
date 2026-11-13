# Dots in the theme's main, secondary and tertiary colors, then its card color. They take the colors of the nearest
# `data-palette` ancestor, which is how a theme tile shows its own palette.
class Components::Swatches < Components::Base
  def view_template
    div(class: "flex gap-1.5") do
      span(class: "size-5 rounded-full bg-primary")
      span(class: "size-5 rounded-full bg-brand-2")
      span(class: "size-5 rounded-full bg-brand-3")
      span(class: "size-5 rounded-full border bg-card")
    end
  end
end
