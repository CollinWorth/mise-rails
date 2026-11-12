class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :planned_meals, dependent: :destroy
  has_one :grocery_list, dependent: :destroy

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :followed
  has_many :follower_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :follower_follows, source: :follower

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP
  validates :password, length: { minimum: 6 }, allow_nil: true

  after_create :create_grocery_list

  scope :named_like, ->(query) { where("name LIKE ?", "%#{sanitize_sql_like(query.strip)}%") }

  def following?(user) = following.exists?(user.id)
end
