# A row in a Menu: a link, a button that submits a request (`action:`), or a plain button (neither) for Stimulus actions.
class Components::MenuItem < Components::Base
  STYLE = "flex w-full items-center gap-2 rounded-md px-3 py-2 text-left text-sm hover:bg-accent focus-visible:bg-accent focus-visible:outline-none"

  def initialize(href: nil, action: nil, method: :post, icon: nil, **attrs)
    @href = href
    @action = action
    @method = method
    @icon = icon
    @attrs = attrs
  end

  def view_template(&content)
    if @action
      ActionForm(action: @action, method: @method) { button(type: :submit, role: "menuitem", class: STYLE, **@attrs) { body(&content) } }
    elsif @href
      a(href: @href, role: "menuitem", class: STYLE, **@attrs) { body(&content) }
    else
      button(type: :button, role: "menuitem", class: STYLE, **@attrs) { body(&content) }
    end
  end

  private
    def body(&content)
      Icon(@icon, class: "size-4 text-muted-foreground") if @icon
      span(&content)
    end
end
