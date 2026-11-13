# Step three's picture: lines that tick themselves off, and one skipped because it's in the pantry.
class Components::Landing::GroceryMock < Components::Base
  def view_template
    Stack do
      aisle("Dairy & Eggs")
      line("milk", "1 gallon", ticked: true, delay: "0.4s")
      line("eggs", "12", ticked: true, delay: "0.9s")
      aisle("Produce", class: "mt-1")
      line("tomatoes", "4")
      Row(class: "flex-nowrap rounded-xl border border-dashed px-3 py-2 text-muted-foreground") do
        Icon(:basket, class: "size-4")
        Text(as: "span", size: "2", class: "flex-1 truncate") { "salt" }
        Text(as: "span", size: "1") { "in your pantry, so skipped" }
      end
    end
  end

  private
    def aisle(name, **attrs)
      Text(as: "span", size: "2", weight: "semibold", class: [ "text-brand-2", attrs[:class] ]) { name }
    end

    def line(name, amount, ticked: false, delay: "0s")
      Card(class: "flex flex-row items-center gap-3 rounded-xl px-3 py-2 shadow-sm") do
        CheckCircle(checked: ticked, animate: true, delay:)
        Text(as: "span", size: "2", weight: "medium", class: [ "flex-1", ("text-muted-foreground line-through" if ticked) ]) { name }
        Text(as: "span", size: "1", weight: "muted") { amount }
      end
    end
end
