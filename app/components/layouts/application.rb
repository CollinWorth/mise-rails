class Components::Layouts::Application < Components::Base
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavascriptImportmapTags

  # Browsers hold on to icons for a long time; bump this when the logo changes (bin/rails icons:generate) so they fetch the new one.
  ICON_VERSION = 2

  # With "match my device" the browser picks the light or dark theme as the phone does, and follows it when it changes
  # (a pinned light or dark appearance is already settled when the page is rendered).
  FOLLOW_DEVICE = <<~JS.squish.freeze
    (function () {
      var root = document.documentElement, query = matchMedia("(prefers-color-scheme: dark)");
      function apply() {
        if (root.dataset.appearance !== "auto") return;
        root.classList.toggle("dark", query.matches);
        root.dataset.palette = query.matches ? root.dataset.darkTheme : root.dataset.lightTheme;
      }
      apply();
      query.addEventListener("change", apply);
    })();
  JS

  def initialize(user: Current.user, bleed: false)
    @user = user
    @bleed = bleed
  end

  def view_template(&)
    doctype
    html(class: ("dark" if appearance == "dark"), data: { appearance:, light_theme:, dark_theme:, palette: palette }) do
      head do
        title { "Mise" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1,viewport-fit=cover")
        meta(name: "theme-color", content: "#c2410c")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "mobile-web-app-capable", content: "yes")
        meta(name: "apple-mobile-web-app-title", content: "Mise")
        meta(name: "apple-mobile-web-app-status-bar-style", content: "black-translucent")
        link(rel: "manifest", href: pwa_manifest_path(format: :json))
        link(rel: "icon", href: "/icon.svg?v=#{ICON_VERSION}", type: "image/svg+xml")
        link(rel: "icon", href: "/favicon-32.png?v=#{ICON_VERSION}", type: "image/png", sizes: "32x32")
        link(rel: "alternate icon", href: "/favicon.ico?v=#{ICON_VERSION}")
        link(rel: "apple-touch-icon", href: "/apple-touch-icon.png?v=#{ICON_VERSION}")
        meta(name: "turbo-refresh-method", content: "morph")
        meta(name: "turbo-refresh-scroll", content: "preserve")
        csrf_meta_tags
        csp_meta_tag
        stylesheet_link_tag "tailwind", data_turbo_track: "reload"
        script { raw(safe(FOLLOW_DEVICE)) } # before the page paints, so "match my device" never flashes the wrong colors
        javascript_importmap_tags
      end
      body(class: "pb-[calc(env(safe-area-inset-bottom)+5rem)] md:pb-0") do
        Navbar(user: @user)
        FlashMessages(flash: flash)
        if @bleed
          yield
        else
          Container do
            Stack do
              yield
            end
          end
        end
        turbo_frame(id: "modal") # full-screen sheets (Components::Sheet) load in here
        TabBar(user: @user) if @user
      end
    end
  end

  private
    def appearance = @user&.appearance || Palette::DEFAULT_APPEARANCE
    def light_theme = @user&.light_theme || Palette::DEFAULT_LIGHT
    def dark_theme = @user&.dark_theme || Palette::DEFAULT_DARK

    # The theme in use when the page is drawn; "match my device" starts light and the early script corrects it.
    def palette = appearance == "dark" ? dark_theme : light_theme
end
