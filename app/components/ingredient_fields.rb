# One editable ingredient row, or a section heading row. Rows are added, removed and reordered in the browser by the
# nested-form Stimulus controller (drag the grip, or use the arrow keys on it); removed saved rows are flagged with _destroy.
class Components::IngredientFields < Components::Base
  def initialize(ingredient:, index:)
    @ingredient = ingredient
    @index = index
  end

  def view_template
    prefix = "recipe[ingredients_attributes][#{@index}]"
    Row(gap: :sm, class: [ "flex-nowrap", ("rounded-lg bg-muted px-2 py-1.5" if @ingredient.section?) ], data: row_data) do
      input(type: :hidden, name: "#{prefix}[id]", value: @ingredient.id) if @ingredient.persisted?
      input(type: :hidden, name: "#{prefix}[_destroy]", value: "0", data: { nested_form_target: "destroy" })
      input(type: :hidden, name: "#{prefix}[position]", value: @index, data: { nested_form_target: "position" })
      grip
      if @ingredient.section?
        input(type: :hidden, name: "#{prefix}[section]", value: "1")
        Input(name: "#{prefix}[name]", value: @ingredient.name, placeholder: "Section, e.g. For the sauce", class: "min-w-0 flex-1 font-semibold", **enter_to_continue)
      else
        Input(name: "#{prefix}[quantity]", value: @ingredient.quantity, placeholder: "Qty", class: "w-14 shrink-0 sm:w-16", **enter_to_continue)
        Input(name: "#{prefix}[unit]", value: @ingredient.unit, placeholder: "Unit", class: "w-16 shrink-0 sm:w-20", **enter_to_continue)
        Input(name: "#{prefix}[name]", value: @ingredient.name, placeholder: "Ingredient", class: "min-w-0 flex-1", **enter_to_continue)
      end
      Button(type: :button, variant: :ghost, size: :sm, class: "size-8 shrink-0 p-0 text-muted-foreground", aria: { label: "Remove #{@ingredient.section? ? 'section' : 'ingredient'}" },
             data: { action: "nested-form#remove" }) { Icon(:x, class: "size-4") }
    end
  end

  private
    def row_data
      { nested_form_target: "item", reorder_item: true, **(@ingredient.section? ? { section: true } : {}) }
    end

    def grip
      Button(type: :button, variant: :ghost, size: :sm, class: "size-8 shrink-0 cursor-grab touch-none p-0 text-muted-foreground", aria: { label: "Move #{@ingredient.section? ? 'section' : 'ingredient'}, or press the up and down arrows" },
             data: { handle: true, action: "keydown.up->nested-form#moveUp keydown.down->nested-form#moveDown" }) { Icon(:grip, class: "size-4") }
    end

    # Return moves to the next row (adding one at the end) instead of submitting the whole form.
    def enter_to_continue
      { enterkeyhint: "next", data: { action: "keydown.enter->nested-form#enter" } }
    end
end
