# Units of measure the app knows how to convert, so "2 cup flour + 1 tbsp flour" can become one line.
# Volume converts to volume and weight to weight; anything else (cloves, a typo, no unit) is never converted.
module Units
  # factor: how many of the family's base unit (teaspoon for volume, gram for weight) one of this unit is.
  Unit = Data.define(:name, :family, :factor)

  KNOWN = [
    Unit.new("tsp", :volume, 1r),
    Unit.new("tbsp", :volume, 3r),
    Unit.new("fl oz", :volume, 6r),
    Unit.new("cup", :volume, 48r),
    Unit.new("pint", :volume, 96r),
    Unit.new("quart", :volume, 192r),
    Unit.new("gallon", :volume, 768r),
    Unit.new("ml", :volume, Rational("0.202884")),
    Unit.new("l", :volume, Rational("202.884")),
    Unit.new("g", :weight, 1r),
    Unit.new("kg", :weight, 1000r),
    Unit.new("oz", :weight, Rational("28.3495")),
    Unit.new("lb", :weight, Rational("453.592"))
  ].index_by(&:name).freeze

  SPELLINGS = {
    "tsp" => %w[tsp tsps teaspoon teaspoons], "tbsp" => %w[tbsp tbsps tbs tbl tablespoon tablespoons],
    "fl oz" => [ "fl oz", "fluid ounce", "fluid ounces" ], "cup" => %w[cup cups],
    "pint" => %w[pint pints pt], "quart" => %w[quart quarts qt], "gallon" => %w[gallon gallons gal],
    "ml" => %w[ml milliliter milliliters millilitre millilitres], "l" => %w[l liter liters litre litres],
    "g" => %w[g gram grams gm], "kg" => %w[kg kilogram kilograms], "oz" => %w[oz ounce ounces],
    "lb" => %w[lb lbs pound pounds]
  }.flat_map { |name, spellings| spellings.map { |spelling| [ spelling, name ] } }.to_h.freeze

  def self.clean(text) = text.to_s.downcase.delete(".").squish

  def self.find(text) = KNOWN[SPELLINGS[clean(text)]]

  # What can be merged with what: known units by family, no unit as "", and any other unit only with itself.
  def self.group(text)
    cleaned = clean(text)
    return "" if cleaned.empty?

    (unit = find(cleaned)) ? unit.family.to_s : "other:#{cleaned.singularize}"
  end

  # Adds up [amount, unit text] pairs that are all in the same group. If they use different known units they are
  # converted to the biggest one and rounded up to the nearest 1/4. Returns [amount, unit text].
  def self.total(parts)
    units = parts.map { |_, text| find(text) }
    if units.all? && units.map(&:name).uniq.size > 1
      biggest = units.each_with_index.max_by { |unit, _| unit.factor }
      base = parts.each_with_index.sum { |(amount, _), index| amount * units[index].factor }
      [ round_up_to_quarter(base / biggest.first.factor), parts[biggest.last].last ]
    else
      [ parts.sum { |amount, _| amount }, parts.first.last ]
    end
  end

  def self.round_up_to_quarter(amount) = (amount * 4).ceil / 4r
end
