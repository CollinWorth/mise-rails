# Step one's picture: a web address, and the recipe it turns into.
class Components::Landing::ImportMock < Components::Base
  def view_template
    Stack do
      Card(class: "flex flex-row items-center gap-2 rounded-xl px-3 py-2.5 text-sm shadow-sm") do
        Icon(:link, class: "size-4 text-brand-2")
        Text(as: "span", size: "2", weight: "muted", class: "truncate") { "kitchen.example/best-lasagna" }
        span(class: "caret -ml-1 inline-block h-4 w-px bg-foreground")
      end
      Card(class: "flex flex-col gap-2.5 rounded-xl p-3.5 shadow-sm") do
        Text(as: "span", weight: "semibold") { "Best Lasagna" }
        Row(gap: :sm) do
          Tag(class: "px-2 py-0.5") { "Prep 20 min" }
          Tag(tone: :tertiary, class: "px-2 py-0.5") { "Italian" }
        end
        [ "500 g beef mince", "2 cups tomato sauce", "9 lasagna sheets" ].each do |line|
          Row(gap: :sm, class: "flex-nowrap") do
            span(class: "size-3.5 rounded-sm border border-muted-foreground/40")
            Text(as: "span", size: "2") { line }
          end
        end
      end
    end
  end
end
