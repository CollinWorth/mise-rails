# The small print at the bottom of the landing page.
class Components::Landing::Footer < Components::Base
  def view_template
    footer(class: "border-t py-8") do
      Row(justify: :between, class: "mx-auto max-w-6xl px-4") do
        Text(as: "span", size: "2", weight: "semibold", class: "inline-flex items-center gap-2") do
          Icon(:chef_hat, class: "size-4 text-primary")
          plain "Mise"
        end
        nav(class: "flex gap-5") do
          TextLink(href: discover_path, class: "text-sm text-muted-foreground") { "Browse recipes" }
          TextLink(href: new_session_path, class: "text-sm text-muted-foreground") { "Sign in" }
          TextLink(href: new_registration_path, class: "text-sm text-muted-foreground") { "Sign up" }
        end
      end
    end
  end
end
