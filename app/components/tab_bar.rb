# Bottom navigation for phones (hidden from md up, where the navbar links show).
class Components::TabBar < Components::Base
  include Components::NavLinks

  def initialize(user:)
    @user = user
  end

  def view_template
    nav(class: "fixed inset-x-0 bottom-0 z-40 border-t bg-background/90 pb-[env(safe-area-inset-bottom)] backdrop-blur md:hidden") do
      div(class: "grid grid-cols-4") { ITEMS.each { |item| tab(item) } }
    end
  end

  private
    def tab(item)
      active = current?(item)
      Link(href: public_send(item[:path]), variant: :ghost, class: [ "h-16 flex-col gap-1 rounded-none px-0 text-xs font-medium", (active ? "text-primary" : "text-muted-foreground") ], aria: { current: ("page" if active) }) do
        Icon(item[:icon], class: "size-6")
        span { item[:label] }
      end
    end
end
