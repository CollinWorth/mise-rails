# A multiple to show a recipe's quantities at, picked with the ?scale= parameter.
# The default (1x) is left out of URLs.
class Scale
  attr_reader :key, :label, :factor

  def initialize(key, label, factor)
    @key = key
    @label = label
    @factor = factor
  end

  ALL = [
    new("0.5", "½×", 1 / 2r),
    new("1", "1×", 1r),
    new("2", "2×", 2r),
    new("3", "3×", 3r)
  ].freeze

  def self.default = ALL.find(&:default?)
  def self.pick(param) = ALL.find { |scale| scale.key == param.to_s } || default

  def default? = factor == 1
  def to_param = (key unless default?)
end
