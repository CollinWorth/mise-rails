# What a list shows when it has nothing in it yet; the block can hold the next step (a button).
class Components::EmptyState < Components::Base
  def initialize(title:, text: nil, icon: :chef_hat)
    @title = title
    @text = text
    @icon = icon
  end

  def view_template(&actions)
    div(class: "flex flex-col items-center gap-3 rounded-xl border border-dashed p-10 text-center") do
      Icon(@icon, class: "size-10 text-muted-foreground")
      Heading(level: 3) { @title }
      Text(class: "max-w-sm text-muted-foreground") { @text } if @text
      Row(gap: :sm, justify: :center, &actions) if actions
    end
  end
end
