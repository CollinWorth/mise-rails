require "test_helper"

class WhatsNewTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Nina")
    @cook.update_column(:whats_new_seen_id, 0)
    sign_in @cook
  end

  test "every entry has a unique id, a date, copy, and a link that goes somewhere" do
    entries = WhatsNew.entries
    assert_equal entries.map(&:id).uniq, entries.map(&:id)
    entries.each do |entry|
      assert entry.title.present? && entry.body.present?, "entry #{entry.id} needs a title and body"
      assert_kind_of Date, entry.date
      assert Rails.application.routes.recognize_path(entry.path.split("?").first), "entry #{entry.id} links nowhere" if entry.path
    end
  end

  test "a cook who has read nothing gets the sheet opening by itself, with every entry, newest first" do
    get recipes_path
    assert_select "turbo-frame#modal[src=?]", whats_new_path

    get whats_new_path, headers: modal_headers
    assert_response :success
    assert_select "[data-whats-new-target=card]", count: WhatsNew.entries.size
    assert_select "[data-whats-new-target=card] h2", text: WhatsNew.entries.first.title
    assert_equal WhatsNew.entries.map(&:title).first, css_select("[data-whats-new-target=card] h2").first.text
  end

  test "reading it marks everything read for the account, and it stays away on every device" do
    patch whats_new_path
    assert_response :no_content
    assert_equal WhatsNew.latest_id, @cook.reload.whats_new_seen_id

    get recipes_path
    assert_select "turbo-frame#modal[src]", count: 0

    delete session_path
    sign_in @cook # another phone
    get recipes_path
    assert_select "turbo-frame#modal[src]", count: 0
  end

  test "only what is new since the last read comes back" do
    @cook.update_column(:whats_new_seen_id, WhatsNew.latest_id - 1)
    get whats_new_path, headers: modal_headers
    assert_select "[data-whats-new-target=card]", count: 1
    assert_select "h2", text: WhatsNew.entries.first.title
  end

  test "the account page can replay everything" do
    @cook.saw_whats_new!
    get recipes_path
    assert_select "turbo-frame#modal[src]", count: 0

    get whats_new_path(all: 1), headers: modal_headers
    assert_select "[data-whats-new-target=card]", count: WhatsNew.entries.size
    get whats_new_path, headers: modal_headers # nothing unread: still shows something rather than an empty sheet
    assert_select "[data-whats-new-target=card]", count: WhatsNew.entries.size

    get profile_path
    assert_select "a[href=?]", whats_new_path(all: 1)
  end

  test "the marker never moves backward, and visitors get no sheet" do
    @cook.update_column(:whats_new_seen_id, 999)
    @cook.saw_whats_new!
    assert_equal 999, @cook.reload.whats_new_seen_id

    delete session_path
    get root_path
    assert_select "turbo-frame#modal[src]", count: 0
    get whats_new_path
    assert_redirected_to new_session_path
  end

  test "opened outside the sheet it sends you back to the page" do
    get whats_new_path
    assert_redirected_to recipes_path
  end
end
