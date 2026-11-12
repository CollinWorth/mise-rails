class Components::Layouts::Application < Components::Base
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavascriptImportmapTags

  def initialize(user: Current.user)
    @user = user
  end

  def view_template(&)
    doctype
    html(class: Current.theme == "dark" ? "dark" : nil) do
      head do
        title { "Mise" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1,viewport-fit=cover")
        meta(name: "theme-color", content: "#c2410c")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "mobile-web-app-capable", content: "yes")
        meta(name: "apple-mobile-web-app-title", content: "Mise")
        meta(name: "apple-mobile-web-app-status-bar-style", content: "black-translucent")
        link(rel: "manifest", href: pwa_manifest_path(format: :json))
        link(rel: "apple-touch-icon", href: "/apple-touch-icon.png")
        meta(name: "turbo-refresh-method", content: "morph")
        meta(name: "turbo-refresh-scroll", content: "preserve")
        csrf_meta_tags
        csp_meta_tag
        stylesheet_link_tag "tailwind", data_turbo_track: "reload"
        javascript_importmap_tags
      end
      body(class: "pt-[env(safe-area-inset-top)] pb-[calc(env(safe-area-inset-bottom)+4.5rem)] md:pb-0") do
        Navbar(user: @user)
        FlashMessages(flash: flash)
        Container do
          Stack do
            yield
          end
        end
        turbo_frame(id: "modal") # full-screen sheets (Components::Sheet) load in here
        TabBar(user: @user) if @user
      end
    end
  end
end
