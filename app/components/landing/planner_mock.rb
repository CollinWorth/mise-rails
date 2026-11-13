# Step two's picture: a few evenings with dinner on them.
class Components::Landing::PlannerMock < Components::Base
  MEALS = [ [ "Mon", "Lasagna", "×2", "from-primary/40 to-brand-2/30" ], [ "Wed", "Chicken tacos", nil, "from-brand-2/40 to-brand-3/30" ], [ "Fri", "Pad Thai", nil, "from-brand-3/40 to-primary/30" ] ].freeze

  def view_template
    Stack(gap: :sm) do
      MEALS.each do |day, meal, times, tile|
        Row(class: "flex-nowrap") do
          Text(as: "span", size: "1", weight: "medium", class: "w-9 uppercase tracking-wide text-muted-foreground") { day }
          Card(class: "flex flex-1 flex-row items-center gap-2.5 rounded-xl p-2 shadow-sm") do
            span(class: [ "size-8 shrink-0 rounded-lg bg-gradient-to-br", tile ])
            Text(as: "span", size: "2", weight: "medium", class: "flex-1 truncate") { meal }
            Text(as: "span", size: "1", weight: "medium", class: "text-brand-3") { times } if times
          end
        end
      end
      Text(size: "1", weight: "muted", class: "ml-12 rounded-xl border border-dashed py-2 text-center") { "+ Add" }
    end
  end
end
