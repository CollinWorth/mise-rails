# The centered title and one-line promise that open a landing section.
class Components::Landing::SectionHeading < Components::Base
  def initialize(title:, subtitle:)
    @title = title
    @subtitle = subtitle
  end

  def view_template
    Stack(gap: :sm, class: "mx-auto mb-12 max-w-2xl text-center", data: { controller: "reveal" }) do
      Heading(level: 2, size: "8", class: "sm:text-4xl") { @title }
      Text(size: "4", weight: "muted") { @subtitle }
    end
  end
end
