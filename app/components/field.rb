# Label + input + validation error for one attribute.
class Components::Field < Components::Base
  def initialize(label:, name:, type: :text, value: nil, errors: [], **input_attrs)
    @label = label
    @name = name
    @type = type
    @value = value
    @errors = errors
    @input_attrs = input_attrs
  end

  def view_template
    FormField do
      FormFieldLabel(for: @name) { @label }
      Input(type: @type, id: @name, name: @name, value: @value, **@input_attrs)
      FormFieldError { @errors.to_sentence } if @errors.any?
    end
  end
end
