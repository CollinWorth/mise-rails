class Components::Container < Components::Base
  def view_template(&) = div(class: "container mx-auto max-w-5xl px-4 py-6", &)
end
