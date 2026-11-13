require "test_helper"

class PaletteIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    sign_in @cook
  end

  test "by default the page follows the device: both themes are on the page for the early script to choose from" do
    get recipes_path
    assert_select "html[data-appearance=auto][data-light-theme=#{Palette::DEFAULT_LIGHT}][data-dark-theme=#{Palette::DEFAULT_DARK}]"
    assert_select "html:not(.dark)"
    assert_select "head script", text: /prefers-color-scheme/
  end

  test "a pinned dark appearance is drawn dark with the chosen dark theme" do
    @cook.update!(appearance: "dark", dark_theme: "deepsea")
    get recipes_path
    assert_select "html.dark[data-palette=deepsea]"
  end

  test "a pinned light appearance is drawn light with the chosen light theme" do
    @cook.update!(appearance: "light", light_theme: "meadow")
    get recipes_path
    assert_select "html[data-palette=meadow]:not(.dark)"
  end

  test "signed-out visitors follow their device with the default themes" do
    delete session_path
    get new_session_path
    assert_select "html[data-appearance=auto][data-palette=#{Palette::DEFAULT_LIGHT}]"
  end

  test "the phone's top bar takes the theme's page color, and both themes' colors are there for the early script" do
    @cook.update!(appearance: "dark", dark_theme: "plum", light_theme: "meadow")
    get recipes_path
    assert_select "meta[name=theme-color][content=?][data-light=?][data-dark=?]", Palette.background("plum"), Palette.background("meadow"), Palette.background("plum")
  end

  test "the installed app's manifest uses the cook's theme color, and works signed out" do
    @cook.update!(appearance: "light", light_theme: "lagoon")
    get pwa_manifest_path(format: :json)
    assert_equal Palette.background("lagoon"), JSON.parse(response.body)["theme_color"]
    assert_equal Palette.background("lagoon"), JSON.parse(response.body)["background_color"]

    delete session_path
    get pwa_manifest_path(format: :json)
    assert_equal Palette.background(Palette::DEFAULT_LIGHT), JSON.parse(response.body)["theme_color"]

    @cook.update!(appearance: "dark", dark_theme: "plum")
    sign_in @cook
    get pwa_manifest_path(format: :json)
    assert_equal Palette.background("plum"), JSON.parse(response.body)["theme_color"]
  end

  test "there is no light/dark toggle button any more" do
    get recipes_path
    assert_select "button[aria-label='Toggle theme']", count: 0
  end

  test "choosing appearance and themes on the profile saves them" do
    patch profile_path, params: { user: { appearance: "light", light_theme: "gruvbox", dark_theme: "gruvboxdark" } }

    assert_redirected_to profile_path
    assert_equal "Appearance updated.", flash[:notice]
    assert_equal %w[light gruvbox gruvboxdark], @cook.reload.then { [ _1.appearance, _1.light_theme, _1.dark_theme ] }
  end

  test "an unknown theme, or one for the wrong mode, is refused and nothing changes" do
    patch profile_path, params: { user: { light_theme: "plum" } }

    assert_response :unprocessable_content
    assert_equal Palette::DEFAULT_LIGHT, @cook.reload.light_theme
  end

  test "the profile lists every theme and the appearance, with the current ones selected" do
    @cook.update!(appearance: "dark", light_theme: "lagoon", dark_theme: "plum")
    get profile_path

    assert_select "input[type=radio][name='user[appearance]']", count: Palette::APPEARANCES.size
    assert_select "input[type=radio][name='user[appearance]'][value=dark][checked]"
    assert_select "input[type=radio][name='user[light_theme]']", count: Palette::LIGHT.size
    assert_select "input[type=radio][value=lagoon][checked]"
    assert_select "input[type=radio][name='user[dark_theme]']", count: Palette::DARK.size
    assert_select "input[type=radio][value=plum][checked]"
    Palette.all.each_value { |name| assert_select "label", text: name }
  end

  test "editing the name keeps the appearance" do
    @cook.update!(appearance: "dark", dark_theme: "plum")
    patch profile_path, params: { user: { name: "Maria L" } }

    assert_equal %w[dark plum], [ @cook.reload.appearance, @cook.dark_theme ]
    assert_equal "Profile updated.", flash[:notice]
  end
end
