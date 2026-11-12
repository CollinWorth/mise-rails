class Components::TextAreaField < Components::Base
  def initialize(label:, name:, value: nil, rows: 6, **attrs)
    @label = label
    @name = name
    @value = value
    @rows = rows
    @attrs = attrs
  end

  def view_template
    FormField do
      FormFieldLabel(for: @name) { @label }
      Textarea(id: @name, name: @name, rows: @rows, **@attrs) { @value }
    end
  end
end
