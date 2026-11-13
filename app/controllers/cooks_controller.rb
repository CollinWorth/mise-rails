class CooksController < ApplicationController
  include RecipeScoped
  allow_unauthenticated_access

  def show
    render Views::Cooks::Show.new(recipe: @recipe, scale: Scale.pick(params[:scale]))
  end
end
