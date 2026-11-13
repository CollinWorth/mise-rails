# The last word: one more way in, on the theme's main color.
class Components::Landing::Closing < Components::Base
  def view_template
    section(class: "mx-auto max-w-6xl px-4 pb-16 lg:pb-24") do
      div(class: "relative overflow-hidden rounded-3xl bg-primary px-6 py-14 text-center text-primary-foreground shadow-xl shadow-primary/20 sm:py-20", data: { controller: "reveal" }) do
        Glow(position: "-right-16 -top-16 size-64 bg-primary-foreground/15", blur: "blur-2xl")
        Glow(position: "-bottom-20 -left-10 size-72 bg-foreground/10", delay: "-6s", blur: "blur-2xl")
        Stack(class: "relative mx-auto max-w-xl items-center") do
          Icon(:chef_hat, class: "size-10")
          Heading(level: 2, size: "9", class: "text-3xl font-extrabold sm:text-5xl") { "Ready when you are." }
          Text(size: "4", class: "opacity-90") { "Your recipes, your week, your grocery list. All in one place, ready on your phone." }
          Link(href: new_registration_path, variant: :secondary, size: :xl, class: "rounded-full bg-background text-foreground shadow-lg hover:bg-background/90") { "Create your account" }
        end
      end
    end
  end
end
