module ImportAudit
  Result = Struct.new(:url, :status, :reason)

  class << self
    attr_writer :cross_checked
    def cross_checked = @cross_checked ||= 0
  end

  def self.check(url, tries: 2)
    body = RemoteFetch.get(url).body.to_s
    return Result.new(url, :skipped, "not a recipe page") unless recipe_page?(body)

    attributes = RecipeImport.new(url:).attributes
    problem = problems(attributes) || disagreement(body, attributes)
    problem ? Result.new(url, :fail, problem) : Result.new(url, :pass)
  rescue RemoteFetch::Refused => error
    error.message.match?(/returned (404|410)/) ? Result.new(url, :skipped, "page is gone") : Result.new(url, :fail, error.message)
  rescue RecipeImport::Failed => error
    Result.new(url, :fail, error.message)
  rescue Errno::ECONNRESET, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => error # the network, not the importer: try again
    (tries -= 1).positive? ? retry : Result.new(url, :fail, "#{error.class}: #{error.message.truncate(80)}")
  rescue StandardError => error
    Result.new(url, :fail, "#{error.class}: #{error.message.truncate(120)}")
  ensure
    sleep 1 # be polite to the sites
  end

  # What a recipe page shows however it's built: schema.org Recipe data, or one of the common recipe-card plugins' markup.
  RECIPE_MARKERS = /"@type"\s*:\s*\[?\s*"Recipe"|class=["'][^"']*(?:wprm-recipe-ingredient|tasty-recipes-ingredients|mv-create-ingredients)|itemprop=["']recipeIngredient/i

  def self.recipe_page?(body) = body.match?(RECIPE_MARKERS)

  # A second opinion that doesn't come from the importer: the number of ingredients the page itself lists in its recipe card
  # (when it uses a card with a countable list) must match what was imported.
  CARD_INGREDIENTS = "li.wprm-recipe-ingredient, .tasty-recipes-ingredients li, .mv-create-ingredients li, [itemprop=recipeIngredient]"

  def self.disagreement(body, attributes)
    listed = Nokogiri::HTML(body).css(CARD_INGREDIENTS).size
    self.cross_checked += 1 if listed.positive?
    imported = attributes[:ingredients_attributes].count { |line| !line[:section] }
    "page lists #{listed} ingredients, imported #{imported}" if listed.positive? && listed != imported
  end

  def self.problems(attributes)
    ingredients = attributes[:ingredients_attributes].reject { |line| line[:section] }
    steps = attributes[:instructions].to_s.lines.map(&:strip).reject(&:empty?)
    return "no name" if attributes[:name].blank?
    return "no ingredients" if ingredients.empty?
    return "no steps" if steps.empty?
    return "an ingredient has no name" if ingredients.any? { |line| line[:name].blank? }
    return "leftover HTML or entities" if [ attributes[:name], *ingredients.map { |line| line[:name] }, *steps ].any? { |text| text.match?(/<\/?\w+[^>]*>|&(?:amp|nbsp|quot|#\d+);/) }
    nil
  end
end
