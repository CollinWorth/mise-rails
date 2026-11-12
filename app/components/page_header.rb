class Components::PageHeader < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template(&actions)
    Row(justify: :between) do
      Heading(level: 1) { @title }
      Row(gap: :sm, &actions) if actions
    end
  end
end
