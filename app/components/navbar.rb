# The sticky top bar: brand, main links (desktop; phones use the TabBar), theme toggle and account menu.
class Components::Navbar < Components::Base
  include Components::NavLinks

  def initialize(user:)
    @user = user
  end

  def view_template
    header(class: "sticky top-0 z-40 border-b bg-background/80 pt-[env(safe-area-inset-top)] backdrop-blur supports-[backdrop-filter]:bg-background/60") do
      div(class: "mx-auto flex h-14 max-w-6xl items-center gap-2 px-4") do
        brand
        links if @user
        div(class: "ml-auto flex items-center gap-1") do
          @user ? account_menu : sign_in_links
        end
      end
    end
  end

  private
    def brand
      Link(href: @user ? recipes_path : root_path, class: "mr-4 h-auto gap-2 px-0 py-0 text-lg font-bold tracking-tight text-foreground") do
        Icon(:chef_hat, class: "text-primary")
        plain "Mise"
      end
    end

    def links
      nav(class: "hidden items-center gap-1 md:flex") do
        ITEMS.each do |item|
          Link(href: public_send(item[:path]), variant: current?(item) ? :secondary : :ghost, size: :sm, class: [ "font-medium", ("text-primary" if current?(item)) ], aria: { current: ("page" if current?(item)) }) { item[:label] }
        end
      end
    end

    def account_menu
      Menu(label: "Account menu", trigger: -> { Avatar(name: @user.name) }) do
        div(class: "px-3 py-2") do
          p(class: "text-sm font-medium") { @user.name }
          p(class: "truncate text-xs text-muted-foreground") { @user.email_address }
        end
        Separator(class: "my-1")
        MenuItem(href: profile_path, icon: :user) { "Your account" }
        MenuItem(href: pantry_items_path, icon: :basket) { "Pantry" }
        MenuItem(href: users_path, icon: :users) { "Find cooks" }
        Separator(class: "my-1")
        MenuItem(action: session_path, method: :delete, icon: :log_out) { "Sign out" }
      end
    end

    def sign_in_links
      Link(href: new_session_path, variant: :ghost, size: :sm) { "Sign in" }
      Link(href: new_registration_path, variant: :primary, size: :sm) { "Sign up" }
    end
end
