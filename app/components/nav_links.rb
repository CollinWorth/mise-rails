# The app's main destinations, shared by the top bar (desktop) and the tab bar (phones).
module Components::NavLinks
  ITEMS = [
    { label: "Discover", icon: :compass, path: :discover_path, match: %r{\A/(discover|users)} },
    { label: "Recipes", icon: :book_open, path: :recipes_path, match: %r{\A/recipes} },
    { label: "Calendar", icon: :calendar, path: :planned_meals_path, match: %r{\A/planned_meals} },
    { label: "Groceries", icon: :basket, path: :grocery_list_path, match: %r{\A/(grocery_list|pantry)} }
  ].freeze

  private
    def current?(item) = view_context.request.path.match?(item[:match])
end
