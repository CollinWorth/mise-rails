# The recipe photo picker: a tappable (or drop-onto) tile that previews the chosen image (see photo_preview_controller.js).
class Components::PhotoField < Components::Base
  include Phlex::Rails::Helpers::URLFor

  def initialize(recipe:)
    @recipe = recipe
  end

  def view_template
    FormField do
      FormFieldLabel(for: "recipe_image") { "Photo" }
      div(data: { controller: "photo-preview" }, class: "relative flex max-w-md flex-col gap-2") do
        tile
        Input(type: :file, id: "recipe_image", name: "recipe[image]", accept: "image/*", class: "sr-only", data: { photo_preview_target: "input", action: "change->photo-preview#show" })
        input(type: :hidden, name: "recipe[image_url]", value: @recipe.image_url) if @recipe.image_url.present?
        remove_option if photo?
      end
    end
  end

  private
    def photo? = @recipe.persisted? && @recipe.image.attached? && @recipe.image.blob.persisted? && @recipe.image.variable?

    def tile
      label(for: "recipe_image", data: { photo_preview_target: "tile", action: "dragover->photo-preview#over dragleave->photo-preview#leave drop->photo-preview#drop" },
            class: "relative flex aspect-video cursor-pointer items-center justify-center overflow-hidden rounded-xl border-2 border-dashed bg-muted/40 text-muted-foreground transition hover:bg-muted data-[over]:border-primary data-[over]:bg-muted") do
        img(src: (url_for(@recipe.image.variant(:card)) if photo?), alt: @recipe.name.to_s, hidden: !photo?, data: { photo_preview_target: "preview" }, class: "absolute inset-0 size-full object-cover")
        div(hidden: photo?, data: { photo_preview_target: "empty" }, class: "flex flex-col items-center gap-1 text-sm") do
          Icon(:camera, class: "size-8")
          span(class: "font-medium text-foreground") { "Add a photo" }
          span { "Tap to choose, or drop one here" }
        end
      end
    end

    def remove_option
      Row(gap: :sm) do
        input(type: :hidden, name: "recipe[remove_image]", value: "0")
        Checkbox(id: "recipe_remove_image", name: "recipe[remove_image]", value: "1")
        FormFieldLabel(for: "recipe_remove_image") { "Remove photo" }
      end
    end
end
