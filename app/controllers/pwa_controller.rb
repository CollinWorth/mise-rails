# The installed app's manifest. Its colors follow the cook's theme (the splash screen and top bar use them).
class PwaController < ApplicationController
  allow_unauthenticated_access

  def manifest
    theme = Current.user&.appearance == "dark" ? Current.user.dark_theme : (Current.user&.light_theme || Palette::DEFAULT_LIGHT)
    color = Palette.background(theme)

    render json: {
      name: "Mise", short_name: "Mise", start_url: "/", scope: "/", display: "standalone",
      description: "Recipes, meal planning and groceries.",
      icons: [
        { src: "/icon-192.png?v=2", type: "image/png", sizes: "192x192", purpose: "any" },
        { src: "/icon.png?v=2", type: "image/png", sizes: "512x512", purpose: "any" },
        { src: "/icon-maskable-512.png?v=2", type: "image/png", sizes: "512x512", purpose: "maskable" }
      ],
      theme_color: color, background_color: color
    }, content_type: "application/manifest+json"
  end
end
