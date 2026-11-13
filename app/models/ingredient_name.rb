# Ingredient names are free text, so "2 large Onions, diced" and "onion" need a common key
# to be recognised as the same thing (pantry matching, merging on the grocery list).
# Only harmless words are stripped: "sweet potato" and "ground beef" stay distinct.
module IngredientName
  NOISE = /\A(?:fresh|organic|large|medium|small|ripe|minced|chopped|diced|sliced|peeled|grated|shredded|melted|softened|unsalted|salted|extra[\s-]virgin)\s+/

  def self.normalize(name)
    text = name.to_s.downcase.strip.sub(/\s*\(.*?\)/, "").sub(/\s*,.*\z/, "").squish
    text = text.sub(NOISE, "") while text.match?(NOISE)
    text.singularize
  end
end
