class Components::SelectField < Components::Base
  CLASSES = "flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"

  def initialize(label:, name:, options:, selected: nil, **attrs)
    @label = label
    @name = name
    @options = options
    @selected = selected
    @attrs = attrs
  end

  def view_template
    FormField do
      FormFieldLabel(for: @name) { @label }
      select(id: @name, name: @name, class: CLASSES, **@attrs) do
        @options.each { |label, value| option(value:, selected: value.to_s == @selected.to_s) { label } }
      end
    end
  end
end
