# Bottom navigation for phones (hidden from md up, where the navbar links show).
class Components::TabBar < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    nav(class: "fixed inset-x-0 bottom-0 z-40 border-t bg-background pb-[env(safe-area-inset-bottom)] md:hidden") do
      div(class: "grid grid-cols-4") do
        tab "Discover", discover_path
        tab "Recipes", recipes_path
        tab "Calendar", planned_meals_path
        tab "Groceries", grocery_list_path
      end
    end
  end

  private
    def tab(label, path)
      Link(href: path, variant: :ghost, size: :lg, class: "h-14 rounded-none") { label }
    end
end
