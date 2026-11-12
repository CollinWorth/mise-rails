# Three-level rating, as in the original app: 1 to 3 stars.
class Components::RatingControl < Components::Base
  def initialize(recipe:, user_rating:)
    @recipe = recipe
    @user_rating = user_rating
  end

  def view_template
    Row(gap: :sm) do
      Text { "Your rating:" }
      (1..3).each do |value|
        ButtonTo(action: recipe_rating_path(@recipe), method: :put, params: { value: },
                 variant: @user_rating.to_i >= value ? :primary : :outline) { "★" }
      end
      ButtonTo(action: recipe_rating_path(@recipe), method: :delete, variant: :ghost) { "Clear" } if @user_rating
    end
  end
end
