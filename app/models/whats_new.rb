# The announcements shown to cooks (config/whats_new.yml). Each cook has a high-water mark, `whats_new_seen_id`, on their
# account: everything up to it is read, so a new phone or browser never shows the same thing twice.
class WhatsNew
  Entry = Data.define(:id, :date, :title, :body, :path)

  FILE = Rails.root.join("config/whats_new.yml")

  # Newest first.
  def self.entries
    @entries ||= YAML.safe_load_file(FILE, permitted_classes: [ Date ]).map { |attrs| Entry.new(path: nil, **attrs.symbolize_keys) }.sort_by { -it.id }.freeze
  end

  def self.latest_id = entries.first&.id.to_i

  def self.unseen(user) = entries.select { it.id > user.whats_new_seen_id }
end
