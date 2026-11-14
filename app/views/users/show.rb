class Views::Users::Show < Views::Base
  def initialize(user:, recipes:, pagy:, collections: [])
    @user = user
    @recipes = recipes
    @pagy = pagy
    @collections = collections
  end

  def page_meta
    cover = @recipes.find { |recipe| share_image(recipe) }
    { title: "#{@user.name}'s recipes", description: "#{@pagy.count} public #{'recipe'.pluralize(@pagy.count)} on Mise", image: (share_image(cover) if cover), url: user_url(@user) }
  end

  def view_template
    PageHeader(title: @user.name) { follow_button }
    Row(gap: :sm) do
      Text { "#{@pagy.count} recipes" }
      TextLink(href: user_followers_path(@user)) { "#{@user.followers.count} followers" }
      TextLink(href: user_following_index_path(@user)) { "#{@user.following.count} following" }
    end
    collections
    RecipeGrid(recipes: @recipes, empty: "No public recipes yet.")
    Pager(pagy: @pagy)
  end

  private
    def collections
      return if @collections.none?

      Heading(level: 3) { "Collections" }
      Grid(columns: 3) { @collections.each { |collection| CollectionCard(collection:) } }
      Heading(level: 3) { "Recipes" }
    end

    def follow_button
      return unless Current.user && Current.user != @user

      if Current.user.following?(@user)
        ButtonTo(action: user_follow_path(@user), method: :delete) { "Unfollow" }
      else
        ButtonTo(action: user_follow_path(@user), variant: :primary) { "Follow" }
      end
    end
end
