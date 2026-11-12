class Views::Users::Index < Views::Base
  def initialize(users:, pagy:, query:)
    @users = users
    @pagy = pagy
    @query = query
  end

  def view_template
    PageHeader(title: "Cooks")
    SearchForm(action: users_path, query: @query, placeholder: "Search by name")
    UserGrid(users: @users)
    Pager(pagy: @pagy)
  end
end
