class Views::Discover::Show < Views::Base
  def initialize(recipes:, pagy:, tab:, query:)
    @recipes = recipes
    @pagy = pagy
    @tab = tab
    @query = query
  end

  def view_template
    PageHeader(title: "Discover") do
      Link(href: users_path, variant: :outline) { "Find cooks" }
    end
    Row(justify: :between) do
      Row(gap: :sm) do
        Link(href: discover_path, variant: @tab == "feed" ? :ghost : :secondary) { "Explore" }
        Link(href: discover_path(tab: :feed), variant: @tab == "feed" ? :secondary : :ghost) { "Following" } if authenticated?
      end
      SearchForm(action: discover_path, query: @query, placeholder: "Search recipes", tab: @tab)
    end
    RecipeGrid(recipes: @recipes, show_author: true, empty: @tab == "feed" ? "Follow some cooks to see their recipes here." : "Nothing to show yet.")
    Pager(pagy: @pagy)
  end

  private
    def authenticated? = Current.user.present?
end
