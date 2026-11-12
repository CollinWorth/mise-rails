class Components::SearchForm < Components::Base
  def initialize(action:, query:, placeholder: "Search", **hidden)
    @action = action
    @query = query
    @placeholder = placeholder
    @hidden = hidden
  end

  def view_template
    ActionForm(action: @action, method: :get) do
      Row(gap: :sm) do
        @hidden.each { |name, value| input(type: :hidden, name: name.to_s, value: value.to_s) }
        Input(type: :search, name: :q, value: @query, placeholder: @placeholder, class: "w-64")
        Button(type: :submit, variant: :secondary) { "Search" }
      end
    end
  end
end
