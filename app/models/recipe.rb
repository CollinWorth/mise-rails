class Recipe < ApplicationRecord
  belongs_to :user
  belongs_to :original, class_name: "Recipe", optional: true
  has_many :versions, -> { where(public: true, modified: true) }, class_name: "Recipe", foreign_key: :original_id, dependent: :nullify
  has_many :ingredients, -> { order(:position) }, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, -> { order(:created_at) }, dependent: :destroy
  has_many :planned_meals, dependent: :destroy
  has_many :grocery_item_sources, dependent: :nullify
  has_one_attached :image do |attachable|
    # Small WebP versions, made right after upload (and by `bin/rails images:variants` for existing photos) so no one waits on the first view.
    # `format` is a string on purpose: a URL carries it back as a string, and a symbol here would fingerprint differently, so the prepared files would never be found.
    attachable.variant :card, resize_to_fill: [ 640, 360 ], format: "webp", saver: { quality: 78 }, preprocessed: true
    attachable.variant :hero, resize_to_fill: [ 900, 675 ], format: "webp", saver: { quality: 80 }, preprocessed: true
  end

  accepts_nested_attributes_for :ingredients, allow_destroy: true, reject_if: ->(attrs) { attrs["name"].blank? }

  # Set when importing from a URL; the image is downloaded on save.
  attr_accessor :image_url

  # Set by the edit form's "Remove photo" checkbox.
  attr_accessor :remove_image

  ACCEPTED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  validates :name, presence: true
  validate :source_url_is_a_web_address
  validate :image_is_a_photo

  before_validation :attach_remote_image, on: :create, if: -> { image_url.present? && !image.attached? }

  before_update :flag_modified, if: -> { original_id? }
  after_save :purge_removed_image

  # Recipes other people can discover: public originals, not saved copies.
  scope :published, -> { where(public: true, original_id: nil) }
  scope :visible_to, ->(user) { where(public: true).or(where(user:)) }
  scope :newest, -> { order(id: :desc) }
  scope :search, ->(query) { where("LOWER(recipes.name) LIKE :q OR LOWER(recipes.tags) LIKE :q OR LOWER(recipes.cuisine) LIKE :q", q: "%#{sanitize_sql_like(query.strip.downcase)}%") if query.present? }

  # A saved copy shares ratings with the recipe it came from.
  def rated_recipe = original || self

  def average_rating
    values = rated_recipe.ratings.map(&:value)
    (values.sum.to_f / values.size).round(1) if values.any?
  end

  def liked_by?(user) = likes.exists?(user:)
  def rating_by(user) = rated_recipe.ratings.find_by(user:)&.value

  def source_host = web_uri(source_url)&.host

  def steps = instructions.to_s.split(/\n+/).map(&:strip).compact_blank
  def total_time = prep_time.to_i + cook_time.to_i

  def copy_for(user)
    dup.tap do |copy|
      copy.assign_attributes(user:, public: false, original: self, modified: false)
      copy.image.attach(image.blob) if image.attached?
      ingredients.each { |ingredient| copy.ingredients.build(ingredient.attributes.slice("name", "quantity", "unit", "section", "position")) }
    end
  end

  private
    def attach_remote_image
      response = RemoteFetch.get(image_url)
      image.attach(io: StringIO.new(response.body), filename: File.basename(URI.parse(image_url).path).presence || "image", content_type: response.content_type)
    rescue RemoteFetch::Refused, URI::InvalidURIError, SocketError, Timeout::Error
      nil
    end

    # Only http(s) links are kept, since the address is shown as a clickable link.
    def source_url_is_a_web_address
      errors.add(:source_url, "must be a web address") if source_url.present? && web_uri(source_url).nil?
    end

    def web_uri(text)
      uri = URI.parse(text.to_s.strip)
      uri if uri.is_a?(URI::HTTP) && uri.host.present?
    rescue URI::InvalidURIError
      nil
    end

    def purge_removed_image
      image.purge_later if ActiveModel::Type::Boolean.new.cast(remove_image) && !attachment_changes["image"]
    end

    def image_is_a_photo
      return unless image.attached?

      errors.add(:image, "must be a JPEG, PNG, WebP or GIF") unless image.content_type.in?(ACCEPTED_IMAGE_TYPES)
      errors.add(:image, "must be under #{MAX_IMAGE_SIZE / 1.megabyte} MB") if image.byte_size > MAX_IMAGE_SIZE
    end

    def flag_modified
      self.modified = true if changed? || ingredients.any?(&:changed?)
    end
end
