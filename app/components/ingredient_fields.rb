# One editable ingredient row, or a section heading row. Rows are added and removed in the
# browser by the nested-form Stimulus controller; removed saved rows are flagged with _destroy.
class Components::IngredientFields < Components::Base
  def initialize(ingredient:, index:)
    @ingredient = ingredient
    @index = index
  end

  def view_template
    prefix = "recipe[ingredients_attributes][#{@index}]"
    Row(gap: :sm, data: { nested_form_target: "item" }) do
      input(type: :hidden, name: "#{prefix}[id]", value: @ingredient.id) if @ingredient.persisted?
      input(type: :hidden, name: "#{prefix}[_destroy]", value: "0", data: { nested_form_target: "destroy" })
      input(type: :hidden, name: "#{prefix}[position]", value: @index)
      if @ingredient.section?
        input(type: :hidden, name: "#{prefix}[section]", value: "1")
        Input(name: "#{prefix}[name]", value: @ingredient.name, placeholder: "Section, e.g. For the sauce", class: "min-w-0 flex-1 basis-40 font-semibold", **enter_to_continue)
      else
        Input(name: "#{prefix}[quantity]", value: @ingredient.quantity, placeholder: "Qty", class: "w-16 shrink-0", **enter_to_continue)
        Input(name: "#{prefix}[unit]", value: @ingredient.unit, placeholder: "Unit", class: "w-20 shrink-0", **enter_to_continue)
        Input(name: "#{prefix}[name]", value: @ingredient.name, placeholder: "Ingredient", class: "min-w-0 flex-1 basis-40", **enter_to_continue)
      end
      Button(type: :button, variant: :ghost, size: :sm, data: { action: "nested-form#remove" }) { "Remove" }
    end
  end

  private
    # Return moves to the next row (adding one at the end) instead of submitting the whole form.
    def enter_to_continue
      { enterkeyhint: "next", data: { action: "keydown.enter->nested-form#enter" } }
    end
end
