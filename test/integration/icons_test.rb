require "test_helper"

class IconsTest < ActionDispatch::IntegrationTest
  # width and height from a PNG's header
  def png_size(path) = Rails.root.join("public", path.sub(/\?.*/, "").delete_prefix("/")).binread(24)[16, 8].unpack("NN")

  test "every page declares a tab icon, a legacy favicon and an iPhone home screen icon" do
    get new_session_path

    assert_select "head link[rel=icon][type='image/svg+xml'][href^='/icon.svg']"
    assert_select "head link[rel=icon][sizes='32x32'][href^='/favicon-32.png']"
    assert_select "head link[rel='alternate icon'][href^='/favicon.ico']"
    assert_select "head link[rel=apple-touch-icon][href^='/apple-touch-icon.png']"
  end

  test "each icon the page points at is served" do
    get new_session_path
    hrefs = css_select("head link[rel*=icon]").map { |link| link["href"] }
    assert_equal 4, hrefs.size

    hrefs.each do |href|
      get href
      assert_response :success, href
    end
  end

  test "the icons are the sizes they claim" do
    assert_equal [ 180, 180 ], png_size("apple-touch-icon.png"), "iPhone icon"
    assert_equal [ 32, 32 ], png_size("favicon-32.png")
    assert_equal [ 192, 192 ], png_size("icon-192.png")
    assert_equal [ 512, 512 ], png_size("icon.png")
    assert_equal [ 512, 512 ], png_size("icon-maskable-512.png")
  end

  test "favicon.ico is a real icon file holding a picture" do
    ico = Rails.root.join("public/favicon.ico")
    assert_equal [ 0, 1, 1 ], ico.binread(6).unpack("vvv"), "an ICO with one image"
    assert_equal "\x89PNG".b, ico.binread(4, 22), "whose picture is a PNG"
  end

  test "the app manifest lists real icons, including one for round and squircle crops" do
    get pwa_manifest_path(format: :json)
    icons = JSON.parse(response.body)["icons"]

    assert_includes icons.map { |icon| icon["purpose"] }, "maskable"
    icons.each do |icon|
      expected = icon["sizes"].split("x").map(&:to_i)
      assert_equal expected, png_size(icon["src"]), "#{icon['src']} is not #{icon['sizes']}"
    end
  end

  test "the logo is a vector file that still draws the hat" do
    svg = Rails.root.join("public/icon.svg").read
    assert_includes svg, "<svg"
    assert_includes svg, "linearGradient"
  end
end
