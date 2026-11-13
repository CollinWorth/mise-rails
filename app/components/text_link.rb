# A link that sits flush with the text around it (RubyUI's link is padded like a button).
class Components::TextLink < Components::Base
  def initialize(href:, **attrs)
    @href = href
    @attrs = attrs
  end

  def view_template(&) = Link(href: @href, **@attrs, class: "h-auto justify-start whitespace-normal px-0 py-0 text-left", &)
end
