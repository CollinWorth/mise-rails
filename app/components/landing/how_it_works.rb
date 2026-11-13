# Three cards, each with a small picture of the app: a link becomes a recipe, a recipe lands on a day, a week becomes one list.
class Components::Landing::HowItWorks < Components::Base
  def view_template
    section(class: "mx-auto max-w-6xl px-4 py-16 lg:py-24") do
      SectionHeading(title: "From a link to dinner, in three taps.", subtitle: "Mise does the busywork between finding a recipe and putting it on the table.")
      Grid(columns: 3) do
        Step(number: 1, title: "Paste a link. Get a recipe.", text: "Found something good online? Drop in the address and Mise pulls out the ingredients and steps. Fix anything, then save it.") { ImportMock() }
        Step(number: 2, title: "Drop it on a day.", text: "Tap + on any recipe and pick the night. Planning for guests? Scale it with one number.", delay: ".1s") { PlannerMock() }
        Step(number: 3, title: "Shop once.", text: "Your week becomes one grocery list, sorted by aisle. Things you always have, like salt and oil, stay off it.", delay: ".2s") { GroceryMock() }
      end
    end
  end
end
