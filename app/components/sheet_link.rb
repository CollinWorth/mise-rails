# A link that opens its target in the full-screen sheet (see Components::Sheet).
class Components::SheetLink < Components::Base
  def initialize(href:, **attrs)
    @href = href
    @attrs = attrs
  end

  def view_template(&) = Link(href: @href, data: { turbo_frame: "modal" }, **@attrs, &)
end
