# A form that submits to a Rails route with CSRF protection and method override,
# so plain RubyUI::Form can be used with resourceful routes.
class Components::ActionForm < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(action:, method: :post, multipart: false, **attrs)
    @action = action
    @method = method.to_sym
    @attrs = attrs
    @attrs[:enctype] = "multipart/form-data" if multipart
  end

  def view_template(&)
    Form(action: @action, method: @method == :get ? :get : :post, **@attrs) do
      input(type: :hidden, name: "_method", value: @method.to_s) unless %i[get post].include?(@method)
      input(type: :hidden, name: "authenticity_token", value: form_authenticity_token) unless @method == :get
      yield
    end
  end
end
