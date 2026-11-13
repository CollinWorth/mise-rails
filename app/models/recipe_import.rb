# Builds recipe attributes from a URL, pasted text, or lines the cook has sorted (see TextReader). Nothing is saved;
# the controller shows the result in the normal recipe form for review.
class RecipeImport
  class Failed < StandardError; end

  # `lines` is an array of { text:, role: } the cook has already looked over; `text` is raw text to read.
  def initialize(params)
    @url = params[:url].to_s.strip
    @text = params[:text].to_s
    @given_lines = params[:lines]
  end

  def from_text? = @url.blank? && (@given_lines.present? || @text.present?)

  # The text as lines with a role each: the cook's own sorting if they have done one, otherwise the reader's guess.
  def lines
    @lines ||= if @given_lines.present?
      @given_lines.map { |line| TextReader::Line.new(text: line[:text].to_s.strip, role: TextReader::ROLES.include?(line[:role]) ? line[:role] : "skip") }.reject { |line| line.text.blank? }
    else
      reader.lines
    end
  end

  # Whether the reader found enough to go straight to the recipe form; otherwise the cook is asked to sort the lines.
  def confident? = @given_lines.present? || reader.confident?

  def attributes
    parsed =
      if @url.present? then from_url
      elsif from_text? then from_lines
      else raise Failed, "Enter a web address or paste the recipe."
      end

    parsed.slice(:name, :prep_time, :cook_time, :servings, :cuisine, :category, :instructions, :image_url, :source_url)
          .merge(ingredients_attributes: parsed[:ingredients].each_with_index.map { |line, position| ingredient_attributes(line).merge(position:) })
  rescue RemoteFetch::Refused => error
    raise Failed, error.message
  end

  private
    def from_url
      document = Nokogiri::HTML(RemoteFetch.get(@url).body)
      data = recipe_json(document) or raise Failed, "No recipe found on that page. Try pasting the text instead."

      {
        source_url: @url.strip,
        name: data["name"], cuisine: Array(data["recipeCuisine"]).first, category: Array(data["recipeCategory"]).first,
        prep_time: minutes(data["prepTime"]), cook_time: minutes(data["cookTime"]),
        servings: Array(data["recipeYield"]).first.to_s[/\d+/]&.to_i,
        ingredients: Array(data["recipeIngredient"]).map { |line| CGI.unescapeHTML(line.to_s) },
        instructions: steps(data["recipeInstructions"]).join("\n"),
        image_url: image_url(data["image"])
      }
    end

    # Most recipe sites embed schema.org Recipe data as JSON-LD.
    def recipe_json(document)
      document.css('script[type="application/ld+json"]').each do |script|
        found = Array.wrap(JSON.parse(script.text)).flat_map { |node| node.is_a?(Hash) ? [ node, *Array.wrap(node["@graph"]) ] : [] }
                                               .find { |node| Array(node["@type"]).include?("Recipe") }
        return found if found
      rescue JSON::ParserError
        next
      end
      nil
    end

    def steps(node)
      case node
      when String then node.split(/\n+/)
      when Array then node.flat_map { |item| steps(item) }
      when Hash then node["itemListElement"] ? steps(node["itemListElement"]) : [ node["text"] ].compact
      else []
      end.map { |step| CGI.unescapeHTML(step.to_s.strip) }.compact_blank
    end

    def minutes(duration)
      ActiveSupport::Duration.parse(duration.to_s).in_minutes.to_i if duration.present?
    rescue ActiveSupport::Duration::ISO8601Parser::ParsingError
      nil
    end

    def image_url(node)
      node = node.first if node.is_a?(Array)
      node.is_a?(Hash) ? node["url"] : node
    end

    def reader = @reader ||= TextReader.new(@text)

    def from_lines
      raise Failed, "There was no text to read." if lines.none?

      {
        name: lines.find { |line| line.role == "title" }&.text.to_s.truncate(120),
        ingredients: lines.filter_map { |line| line.role == "heading" ? { section: line.text } : (line.text if line.role == "ingredient") },
        instructions: lines.select { |line| line.role == "step" }.map(&:text).join("\n")
      }.merge(TextReader.facts(lines))
    end

    def ingredient_attributes(line)
      return { name: line[:section], section: true, quantity: "", unit: "" } if line.is_a?(Hash)

      parsed = Ingreedy.parse(line)
      quantity = parsed.amount ? Quantity.format(parsed.amount.to_r.rationalize(Rational(1, 64))) : ""
      { name: parsed.ingredient.to_s.strip, quantity:, unit: parsed.unit.to_s }
    rescue Ingreedy::ParseFailed, StandardError
      { name: line, quantity: "", unit: "" }
    end
end
