class Components::UserGrid < Components::Base
  def initialize(users:, empty: "No cooks found.")
    @users = users
    @empty = empty
  end

  def view_template
    return Text { @empty } if @users.none?

    Grid(columns: 3) do
      @users.each do |user|
        Card { CardHeader { CardTitle { Link(href: user_path(user)) { user.name } } } }
      end
    end
  end
end
