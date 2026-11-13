# The profile's appearance settings: follow the device (or pin light or dark), and pick a light and a dark theme.
# Changes show at once (appearance_controller.js) and save by themselves (autosubmit).
class Components::AppearancePicker < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    ActionForm(action: profile_path, method: :patch, data: { controller: "autosubmit appearance", action: "change->appearance#preview change->autosubmit#queue" }) do
      Stack(gap: :lg) do
        modes
        themes("Light theme", "light_theme", Palette::LIGHT, @user.light_theme)
        themes("Dark theme", "dark_theme", Palette::DARK, @user.dark_theme)
      end
    end
  end

  private
    def modes
      fieldset(class: "flex flex-col gap-2") do
        legend(class: "mb-2 text-sm font-medium") { "Light or dark" }
        div(class: "inline-flex w-fit gap-1 rounded-lg bg-muted p-1") do
          Palette::APPEARANCES.each do |key, name|
            label(class: "cursor-pointer") do
              input(type: :radio, name: "user[appearance]", value: key, checked: key == @user.appearance, class: "peer sr-only")
              span(class: "block rounded-md px-3 py-1.5 text-sm font-medium text-muted-foreground transition peer-checked:bg-background peer-checked:text-foreground peer-checked:shadow-sm peer-focus-visible:ring-2 peer-focus-visible:ring-ring") { name }
            end
          end
        end
        Text(size: "2", class: "text-muted-foreground") { "Match my device follows your phone's light and dark setting, day and night." }
      end
    end

    def themes(title, field, options, selected)
      fieldset(class: "flex flex-col gap-2") do
        legend(class: "mb-2 text-sm font-medium") { title }
        div(class: "grid grid-cols-2 gap-3 sm:grid-cols-4") { options.each { |key, name| tile(field, key, name, selected) } }
      end
    end

    # A tile drawn in its own theme's colors, so choosing is seeing.
    def tile(field, key, name, selected)
      label(class: "cursor-pointer") do
        input(type: :radio, name: "user[#{field}]", value: key, checked: key == selected, class: "peer sr-only")
        div(data: { palette: key }, class: "flex flex-col gap-2 rounded-xl border-2 bg-background p-3 text-foreground transition peer-checked:border-primary peer-focus-visible:ring-2 peer-focus-visible:ring-ring") do
          div(class: "flex gap-1.5") do
            span(class: "size-5 rounded-full bg-primary")
            span(class: "size-5 rounded-full bg-brand-2")
            span(class: "size-5 rounded-full bg-brand-3")
            span(class: "size-5 rounded-full border bg-card")
          end
          span(class: "text-sm font-medium") { name }
        end
      end
    end
end
