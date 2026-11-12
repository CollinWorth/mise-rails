class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :value, inclusion: { in: 1..3 }
  validates :recipe_id, uniqueness: { scope: :user_id }
end
