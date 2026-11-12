# Shared by the followers and following lists.
class Views::Users::Connections::Index < Views::Base
  def initialize(user:, users:, pagy:, title:)
    @user = user
    @users = users
    @pagy = pagy
    @title = title
  end

  def view_template
    PageHeader(title: @title) { Link(href: user_path(@user), variant: :outline) { "Back" } }
    UserGrid(users: @users, empty: "Nobody yet.")
    Pager(pagy: @pagy)
  end
end
