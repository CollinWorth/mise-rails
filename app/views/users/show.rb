class Views::Users::Show < Views::Base
  def initialize(user:, recipes:, pagy:)
    @user = user
    @recipes = recipes
    @pagy = pagy
  end

  def view_template
    PageHeader(title: @user.name) { follow_button }
    Row(gap: :sm) do
      Text { "#{@pagy.count} recipes" }
      Link(href: user_followers_path(@user)) { "#{@user.followers.count} followers" }
      Link(href: user_following_index_path(@user)) { "#{@user.following.count} following" }
    end
    RecipeGrid(recipes: @recipes, empty: "No public recipes yet.")
    Pager(pagy: @pagy)
  end

  private
    def follow_button
      return unless Current.user && Current.user != @user

      if Current.user.following?(@user)
        ButtonTo(action: user_follow_path(@user), method: :delete) { "Unfollow" }
      else
        ButtonTo(action: user_follow_path(@user), variant: :primary) { "Follow" }
      end
    end
end
