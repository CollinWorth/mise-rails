class CooksController < ApplicationController
  include RecipeScoped
  allow_unauthenticated_access

  def show
    render Views::Cooks::Show.new(recipe: @recipe, scale: Recipe.scale_key(params[:scale]))
  end
end
