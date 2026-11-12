class Components::Navbar < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    Container do
      Row(justify: :between) do
        Row(gap: :sm) do
          Link(href: root_path) { Heading(level: 3) { "Mise" } }
          Link(href: discover_path) { "Discover" }
          if @user
            Row(gap: :sm, class: "hidden md:flex") do
              Link(href: recipes_path) { "My recipes" }
              Link(href: planned_meals_path) { "Calendar" }
              Link(href: grocery_list_path) { "Groceries" }
            end
          end
        end
        Row(gap: :sm) do
          Button(variant: :ghost, size: :sm, data: { controller: "theme", action: "theme#toggle" }) { "Theme" }
          if @user
            Link(href: profile_path) { @user.name }
            ActionForm(action: session_path, method: :delete, class: "hidden md:block") { Button(type: :submit, variant: :ghost, size: :sm) { "Sign out" } }
          else
            Link(href: new_session_path) { "Sign in" }
            Link(href: new_registration_path) { "Sign up" }
          end
        end
      end
    end
    Separator()
  end
end
