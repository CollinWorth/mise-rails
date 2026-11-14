# Named groups of recipes. Anyone can open a public one; everything else is the owner's.
class CollectionsController < ApplicationController
  allow_unauthenticated_access only: :show
  before_action :set_collection, only: %i[edit update destroy]

  def index
    render Views::Collections::Index.new(collections: Current.user.collections.newest.to_a)
  end

  def show
    collection = Collection.visible_to(Current.user).find(params[:id])
    pagy, recipes = pagy(:offset, collection.recipes_for(Current.user).with_attached_image.includes(:ratings, :user), limit: 24)
    render Views::Collections::Show.new(collection:, recipes:, pagy:)
  end

  def new
    render Views::Collections::New.new(collection: Current.user.collections.build)
  end

  # Made from a recipe's sheet (with `recipe_id`), the new collection starts with that recipe in it.
  def create
    collection = Current.user.collections.build(collection_params)
    if collection.save
      recipe = Recipe.visible_to(Current.user).find_by(id: params[:recipe_id])
      collection.add(recipe) if recipe
      redirect_to (recipe ? recipe_path(recipe) : collection_path(collection)), notice: (recipe ? "Added #{recipe.name} to #{collection.name}." : "Collection created."), status: :see_other
    else
      render Views::Collections::New.new(collection:, recipe_id: params[:recipe_id].presence), status: :unprocessable_content
    end
  end

  def edit
    render Views::Collections::Edit.new(collection: @collection)
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: "Collection saved.", status: :see_other
    else
      render Views::Collections::Edit.new(collection: @collection), status: :unprocessable_content
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, notice: "Deleted #{@collection.name}.", status: :see_other
  end

  private
    def set_collection = @collection = Current.user.collections.find(params[:id])

    def collection_params = params.expect(collection: %i[name description public])
end
