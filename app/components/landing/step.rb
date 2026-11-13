# One "how it works" card: a small picture of the app on top (the block), then the step's number, title and sentence.
class Components::Landing::Step < Components::Base
  def initialize(number:, title:, text:, delay: "0s")
    @number = number
    @title = title
    @text = text
    @delay = delay
  end

  def view_template(&picture)
    Card(class: "flex flex-col gap-5 rounded-3xl p-5 shadow-sm", data: { controller: "reveal" }, style: "--delay: #{@delay}") do
      div(class: "min-h-64 rounded-2xl bg-muted p-4", aria_hidden: "true", &picture)
      Stack(gap: :sm) do
        NumberBadge(number: @number)
        Heading(level: 3, size: "5", class: "font-semibold") { @title }
        Text(weight: "muted") { @text }
      end
    end
  end
end
