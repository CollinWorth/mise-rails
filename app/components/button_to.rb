# A button that submits a one-off request, like Rails' button_to.
class Components::ButtonTo < Components::Base
  def initialize(action:, method: :post, variant: :outline, size: :sm, params: {})
    @action = action
    @method = method
    @variant = variant
    @size = size
    @params = params
  end

  def view_template(&)
    ActionForm(action: @action, method: @method, class: "inline") do
      @params.each { |name, value| input(type: :hidden, name: name.to_s, value: value.to_s) }
      Button(type: :submit, variant: @variant, size: @size, &)
    end
  end
end
