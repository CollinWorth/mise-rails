# The "What's new" sheet: the announcements one card at a time, with "Close" skipping the rest.
class Views::WhatsNew::Show < Views::Base
  def initialize(entries:)
    @entries = entries
  end

  def view_template
    Sheet(title: "What's new") { WhatsNewPager(entries: @entries, seen_url: whats_new_path) }
  end
end
