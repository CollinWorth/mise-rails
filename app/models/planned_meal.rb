class PlannedMeal < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :date, presence: true
  validates :multiplier, numericality: { only_integer: true, greater_than: 0 }

  scope :between, ->(range) { where(date: range) }
end
