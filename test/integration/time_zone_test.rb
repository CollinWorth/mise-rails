require "test_helper"

class TimeZoneTest < ActionDispatch::IntegrationTest
  # 3:00 UTC on the 16th is still the evening of the 15th in Pacific time and already midday on the 16th in Tokyo.
  AT = Time.utc(2026, 11, 16, 3)

  setup do
    @cook = create_user(name: "Maria")
    @soup = create_recipe(@cook, name: "Soup")
    sign_in @cook
  end

  test "days are Pacific until a zone is known" do
    travel_to(AT) { post recipe_cooking_path(@soup) }
    assert_equal Date.new(2026, 11, 15), @cook.cookings.last.cooked_on
  end

  test "the device's zone, sent in a cookie, sets the day" do
    cookies[:time_zone] = "Asia/Tokyo"
    travel_to(AT) { post recipe_cooking_path(@soup) }
    assert_equal Date.new(2026, 11, 16), @cook.cookings.last.cooked_on
  end

  test "a zone chosen on the profile beats the device's" do
    cookies[:time_zone] = "Asia/Tokyo"
    patch profile_path, params: { user: { time_zone: "America/New_York" } }
    assert_equal "America/New_York", @cook.reload.time_zone

    travel_to(Time.utc(2026, 11, 16, 3, 30)) { post recipe_cooking_path(@soup) }
    assert_equal Date.new(2026, 11, 15), @cook.cookings.last.cooked_on
  end

  test "picking match my device clears the choice, and a made-up zone is refused" do
    @cook.update!(time_zone: "Asia/Tokyo")
    patch profile_path, params: { user: { time_zone: "" } }
    assert_nil @cook.reload.time_zone

    patch profile_path, params: { user: { time_zone: "Mars/Olympus" } }
    assert_response :unprocessable_content
    assert_nil @cook.reload.time_zone
  end

  test "a junk zone cookie is ignored" do
    cookies[:time_zone] = "Mars/Olympus"
    travel_to(AT) { post recipe_cooking_path(@soup) }
    assert_equal Date.new(2026, 11, 15), @cook.cookings.last.cooked_on
  end

  test "the profile page offers the choice" do
    get profile_path
    assert_select "select[name='user[time_zone]'] option", text: "Match my device"
  end
end
