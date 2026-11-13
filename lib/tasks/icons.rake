require "vips"

# The Mise logo (a chef's toque on the brand-orange gradient) lives here, and every icon is drawn from it:
#   bin/rails icons:generate
# Change the colors or the shape below, run the task, and commit what it writes to public/.
namespace :icons do
  HAT = <<~SVG.squish.freeze
    <g fill="#000" opacity=".16" transform="translate(0 10)">
      <circle cx="186" cy="214" r="66"/><circle cx="256" cy="184" r="82"/><circle cx="326" cy="214" r="66"/>
      <rect x="176" y="214" width="160" height="120"/><rect x="164" y="322" width="184" height="60" rx="18"/>
    </g>
    <g fill="#fffaf5">
      <circle cx="186" cy="214" r="66"/><circle cx="256" cy="184" r="82"/><circle cx="326" cy="214" r="66"/>
      <rect x="176" y="214" width="160" height="120"/><rect x="164" y="322" width="184" height="60" rx="18"/>
    </g>
    <path d="M226 262v52M286 262v52" stroke="#f1d3bf" stroke-width="9" stroke-linecap="round"/>
  SVG

  # corner: roundness of the tile (0 for iOS, which rounds icons itself); mark: how big the hat is drawn.
  def logo(corner:, mark:)
    <<~SVG.squish
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
        <defs>
          <linearGradient id="tile" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#fb923c"/><stop offset="1" stop-color="#b93a0a"/></linearGradient>
          <radialGradient id="glow" cx=".28" cy=".18" r=".8"><stop offset="0" stop-color="#fff" stop-opacity=".38"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>
        </defs>
        <rect width="512" height="512" rx="#{corner}" fill="url(#tile)"/>
        <rect width="512" height="512" rx="#{corner}" fill="url(#glow)"/>
        <g transform="translate(256 256) scale(#{mark}) translate(-256 -242)">#{HAT}</g>
      </svg>
    SVG
  end

  def png(svg, size) = Vips::Image.svgload_buffer(svg, scale: size / 512.0).write_to_buffer(".png")

  desc "Draw the logo and write the favicon, iPhone, and app icons to public/"
  task generate: :environment do
    # Rails tells libvips not to open SVGs (they can be hostile when uploaded); this one is our own, so allow it just here.
    Vips.block_untrusted(false)
    public = Rails.root.join("public")
    rounded = logo(corner: 112, mark: 1.22)
    square = logo(corner: 0, mark: 1.22)
    maskable = logo(corner: 0, mark: 1.0) # keeps the hat inside the circle phones crop app icons to

    files = {
      "icon.svg" => rounded,
      "icon.png" => png(rounded, 512),
      "icon-192.png" => png(rounded, 192),
      "icon-maskable-512.png" => png(maskable, 512),
      "apple-touch-icon.png" => png(square, 180),
      "favicon-32.png" => png(rounded, 32)
    }
    ico = png(rounded, 48) # an .ico can hold a PNG, which every current browser reads
    files["favicon.ico"] = [ 0, 1, 1 ].pack("vvv") + [ 48, 48, 0, 0, 1, 32, ico.bytesize, 22 ].pack("CCCCvvVV") + ico

    files.each { |name, data| public.join(name).binwrite(data) }
    puts "Wrote #{files.keys.to_sentence}."
  ensure
    Vips.block_untrusted(true)
  end
end
