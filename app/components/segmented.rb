# A row of linked options where the current one is raised, like iOS's segmented control (Discover's tabs, recipe scale).
class Components::Segmented < Components::Base
  def view_template
    nav(class: "inline-flex items-center gap-1 rounded-lg bg-muted p-1") { yield self }
  end

  def option(label, href, active:, **attrs)
    Link(href:, variant: :ghost, size: :sm, aria: { current: ("page" if active) },
         class: [ "rounded-md px-3 font-medium", (active ? "bg-background text-foreground shadow-sm hover:bg-background" : "text-muted-foreground hover:text-foreground") ], **attrs) { label }
  end
end
