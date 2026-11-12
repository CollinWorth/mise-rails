# Builds recipe attributes from a URL or pasted text. Nothing is saved;
# the controller shows the result in the normal recipe form for review.
class RecipeImport
  class Failed < StandardError; end

  HEADERS = { ingredients: /\Aingredients?:?\z/i, instructions: /\A(instructions?|directions?|method|steps?|preparation):?\z/i }.freeze

  def initialize(params)
    @url = params[:url].to_s.strip
    @text = params[:text].to_s
  end

  def attributes
    parsed =
      if @url.present? then from_url
      elsif @text.present? then from_text(@text)
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

    def from_text(text)
      lines = text.lines.map(&:strip).compact_blank
      section = nil
      parsed = { name: lines.first.to_s.truncate(120), ingredients: [], instructions: [] }

      lines.drop(1).each do |line|
        if (header = HEADERS.find { |_, pattern| line.match?(pattern) })
          section = header.first
        elsif section
          parsed[section] << line
        elsif line.match?(/\A[\d½¼¾⅓⅔⅛]/)
          parsed[:ingredients] << line
        else
          parsed[:instructions] << line
        end
      end

      parsed.merge(instructions: parsed[:instructions].join("\n"))
    end

    def ingredient_attributes(line)
      parsed = Ingreedy.parse(line)
      quantity = parsed.amount ? Quantity.format(parsed.amount.to_r.rationalize(Rational(1, 64))) : ""
      { name: parsed.ingredient.to_s.strip, quantity:, unit: parsed.unit.to_s }
    rescue Ingreedy::ParseFailed, StandardError
      { name: line, quantity: "", unit: "" }
    end
end
