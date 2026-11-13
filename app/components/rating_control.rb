# Three-level rating, as in the original app: 1 to 3 stars.
class Components::RatingControl < Components::Base
  def initialize(recipe:, user_rating:)
    @recipe = recipe
    @user_rating = user_rating
  end

  def view_template
    Row(gap: :sm) do
      Text(size: "2", class: "text-muted-foreground") { "Your rating" }
      Row(gap: :sm, class: "gap-0") do
        (1..3).each do |value|
          ButtonTo(action: recipe_rating_path(@recipe), method: :put, params: { value: }, variant: :ghost,
                   button_class: [ "px-1.5 text-xl", (@user_rating.to_i >= value ? "text-primary" : "text-muted-foreground/50") ]) { "★" }
        end
      end
      ButtonTo(action: recipe_rating_path(@recipe), method: :delete, variant: :ghost, button_class: "text-xs text-muted-foreground") { "Clear" } if @user_rating
    end
  end
end
