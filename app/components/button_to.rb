# A button that submits a one-off request, like Rails' button_to.
class Components::ButtonTo < Components::Base
  def initialize(action:, method: :post, variant: :outline, size: :sm, params: {}, **form_attrs)
    @action = action
    @method = method
    @variant = variant
    @size = size
    @params = params
    @form_attrs = form_attrs
  end

  def view_template(&)
    ActionForm(action: @action, method: @method, class: "inline", **@form_attrs) do
      @params.each { |name, value| input(type: :hidden, name: name.to_s, value: value.to_s) }
      Button(type: :submit, variant: @variant, size: @size, &)
    end
  end
end
