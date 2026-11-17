class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :pantry_items, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :planned_meals, dependent: :destroy
  has_many :cookings, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_one :grocery_list, dependent: :destroy

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :followed
  has_many :follower_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :follower_follows, source: :follower

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :time_zone, with: ->(name) { name.presence }

  validates :name, presence: true
  validates :appearance, inclusion: { in: Palette::APPEARANCES.keys }
  validates :light_theme, inclusion: { in: Palette::LIGHT.keys }
  validates :dark_theme, inclusion: { in: Palette::DARK.keys }
  validate { errors.add(:time_zone, :inclusion) if time_zone && !ActiveSupport::TimeZone[time_zone] }
  validates :email_address, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP
  validates :password, length: { minimum: 6 }, allow_nil: true

  after_create :create_grocery_list

  scope :named_like, ->(query) { where("LOWER(name) LIKE ?", "%#{sanitize_sql_like(query.strip.downcase)}%") }

  # A new key for the Siri Shortcut (the old one stops working). It is returned once; only its digest is kept.
  def regenerate_shortcut_token
    SecureRandom.base58(32).tap { |token| update!(shortcut_token_digest: self.class.digest_shortcut_token(token)) }
  end

  def self.find_by_shortcut_token(token)
    find_by(shortcut_token_digest: digest_shortcut_token(token)) if token.present?
  end

  def self.digest_shortcut_token(token) = Digest::SHA256.hexdigest(token.to_s)

  def pantry_keys = pantry_items.pluck(:normalized_name)

  def following?(user) = following.exists?(user.id)

  def saw_whats_new! = update_column(:whats_new_seen_id, [ whats_new_seen_id, WhatsNew.latest_id ].max)
end
