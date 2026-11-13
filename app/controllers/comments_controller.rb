class CommentsController < ApplicationController
  include RecipeScoped
  skip_before_action :set_recipe, only: :destroy

  def create
    comment = @recipe.comments.build(params.expect(comment: :body).merge(user: Current.user))
    comment.save
    redirect_back_or_to @recipe, alert: comment.errors.full_messages.to_sentence.presence, status: :see_other
  end

  def destroy
    comment = Current.user.comments.find(params[:id])
    comment.destroy
    redirect_back_or_to comment.recipe, status: :see_other
  end
end
