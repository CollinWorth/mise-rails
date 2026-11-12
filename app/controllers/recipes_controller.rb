class RecipesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_recipe, only: %i[show edit update destroy]
  before_action :require_owner, only: %i[edit update destroy]

  def index
    return redirect_to discover_path unless authenticated?

    pagy, recipes = pagy(:offset, Current.user.recipes.search(params[:q]).with_attached_image.includes(:ratings, original: %i[user ratings]).newest, limit: 12)
    render Views::Recipes::Index.new(recipes:, pagy:, query: params[:q].to_s)
  end

  def show
    render Views::Recipes::Show.new(recipe: @recipe, scale: Recipe.scale_key(params[:scale]))
  end

  def new
    render Views::Recipes::New.new(recipe: Current.user.recipes.build)
  end

  def create
    recipe = Current.user.recipes.build(recipe_params)
    if recipe.save
      redirect_to recipe, notice: "Recipe saved."
    else
      render Views::Recipes::New.new(recipe:), status: :unprocessable_content
    end
  end

  def edit
    render Views::Recipes::Edit.new(recipe: @recipe)
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Recipe updated."
    else
      render Views::Recipes::Edit.new(recipe: @recipe), status: :unprocessable_content
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: "Recipe deleted.", status: :see_other
  end

  private
    def set_recipe
      @recipe = Recipe.visible_to(Current.user).find(params[:id])
    end

    def require_owner
      head :forbidden unless @recipe.user == Current.user
    end

    def recipe_params
      params.expect(recipe: [ :name, :instructions, :prep_time, :cook_time, :servings, :cuisine, :category, :tags, :public, :image, :remove_image,
                              ingredients_attributes: [ %i[id name quantity unit section position _destroy] ] ])
    end
end
