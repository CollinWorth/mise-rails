# A recipe's comments, newest last, with a box to add one when signed in.
class Components::Comments < Components::Base
  def initialize(recipe:)
    @recipe = recipe
  end

  def view_template
    Stack(class: "max-w-2xl") do
      Heading(level: 3) { "Comments (#{@recipe.comments.size})" }
      @recipe.comments.includes(:user).each { |comment| row(comment) }
      form if Current.user
    end
  end

  private
    def row(comment)
      Row(gap: :sm, class: "flex-nowrap items-start") do
        Avatar(name: comment.user.name)
        Stack(gap: :sm, class: "min-w-0 flex-1") do
          Row(gap: :sm, justify: :between) do
            Row(gap: :sm) do
              Text(as: "span", size: "2", weight: "medium") { comment.user.name }
              Text(as: "span", size: "1", class: "text-muted-foreground") { "#{view_context.time_ago_in_words(comment.created_at)} ago" }
            end
            ButtonTo(action: recipe_comment_path(@recipe, comment), method: :delete, variant: :ghost, button_class: "h-auto px-1 py-0 text-xs text-muted-foreground") { "Delete" } if comment.user == Current.user
          end
          Text { comment.body }
        end
      end
    end

    def form
      ActionForm(action: recipe_comments_path(@recipe)) do
        Stack(gap: :sm) do
          TextAreaField(label: "Add a comment", name: "comment[body]", rows: 3)
          Button(type: :submit, class: "self-start") { "Post" }
        end
      end
    end
end
