class Ingredient < ApplicationRecord
  include Quantified

  belongs_to :recipe

  validates :name, presence: true
end
