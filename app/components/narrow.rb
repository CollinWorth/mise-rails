# A centered column for list pages (grocery list, pantry): long rows are hard to read across a wide desktop.
class Components::Narrow < Components::Base
  def view_template(&) = div(class: "mx-auto flex w-full max-w-2xl flex-col gap-4", &)
end
