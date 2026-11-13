require "test_helper"

class PaletteIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    sign_in @cook
  end

  test "pages use the signed-in cook's palette" do
    get recipes_path
    assert_select "html[data-palette=#{Palette::DEFAULT}]"

    @cook.update!(palette: "ocean")
    get recipes_path
    assert_select "html[data-palette=ocean]"
  end

  test "signed-out visitors get the default palette" do
    delete session_path
    get new_session_path
    assert_select "html[data-palette=#{Palette::DEFAULT}]"
  end

  test "choosing a palette on the profile saves it" do
    patch profile_path, params: { user: { palette: "forest" } }

    assert_redirected_to profile_path
    assert_equal "Palette changed.", flash[:notice]
    assert_equal "forest", @cook.reload.palette
  end

  test "an unknown palette is refused and nothing changes" do
    patch profile_path, params: { user: { palette: "neon" } }

    assert_response :unprocessable_content
    assert_equal Palette::DEFAULT, @cook.reload.palette
  end

  test "the profile lists every palette with the current one selected" do
    @cook.update!(palette: "plum")
    get profile_path

    assert_select "input[type=radio][name='user[palette]']", count: Palette.keys.size
    assert_select "input[type=radio][value=plum][checked]"
    Palette::NAMES.each_value { |name| assert_select "label", text: name }
  end

  test "editing the name keeps the palette" do
    @cook.update!(palette: "harvest")
    patch profile_path, params: { user: { name: "Maria L" } }

    assert_equal "harvest", @cook.reload.palette
    assert_equal "Profile updated.", flash[:notice]
  end
end
