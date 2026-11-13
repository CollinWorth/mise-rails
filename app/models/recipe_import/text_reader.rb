# Reads recipe text (typed, copied from a page or PDF, or scanned off a cookbook with the iPhone's Scan Text) into lines, each
# with a guess at its role. The guesses are shown to the cook to correct (Components::LineSorter) before a recipe is built.
#
# Roles: title, meta (servings and times), ingredient, heading (a section such as "For the sauce"), step, skip.
# Headings like "Ingredients" and "Directions" are the best guide; without them the shape of each line decides.
class RecipeImport::TextReader
  Line = Data.define(:text, :role)

  ROLES = %w[title meta ingredient heading step skip].freeze

  INGREDIENTS_HEADER = /\A(?:the\s+)?(?:ingredients?|what you(?:'ll| will)? need|you(?:'ll| will) need|shopping list)\s*:?\z/i
  STEPS_HEADER = /\A(?:instructions?|directions?|method|steps?|preparation|procedure|how to make(?: it)?)\s*:?\z/i
  SKIPPED_HEADER = /\A(?:notes?|tips?|nutrition(?: facts| information)?|storage|equipment|reviews?|comments?)\s*:?\z/i

  SERVINGS = /\A(?:serves|servings?|makes|yields?)\s*:?\s*(\d+)\b/i
  PREP = /\Aprep(?:aration)?\s*(?:time\s*:?|:)\s*(\d.*)\z/i
  COOK = /\A(?:cook(?:ing)?|bake|baking)\s*(?:time\s*:?|:)\s*(\d.*)\z/i
  TOTAL = /\Atotal\s*(?:time\s*:?|:)\s*\d.*\z/i

  BULLET = /\A[•●○▪▫■□☐☑☒◦⁃✓*·▢☐\-–—]+\s*/
  NUMBERED = /\A(?:step\s*)?\d{1,2}[.):]\s+/i
  WRAP_WIDTH = 15
  QUANTITY = /\A(?:\d|[½¼¾⅓⅔⅛⅜⅝⅞]|(?:pinch|dash|handful|splash|knob)\b)/i

  # Servings and times found in the lines marked meta, as recipe attributes.
  def self.facts(lines)
    lines.select { |line| line.role == "meta" }.each_with_object({}) do |line, facts|
      if (match = line.text.match(SERVINGS)) then facts[:servings] = match[1].to_i
      elsif (match = line.text.match(PREP)) then facts[:prep_time] = minutes(match[1])
      elsif (match = line.text.match(COOK)) then facts[:cook_time] = minutes(match[1])
      end
    end.compact
  end

  # "1 hour 15 minutes", "45 min", "20" (minutes are assumed) -> minutes.
  def self.minutes(text)
    hours = text[/(\d+(?:\.\d+)?)\s*(?:hours?|hrs?|h)\b/i, 1]
    mins = text[/(\d+)\s*(?:minutes?|mins?|m)\b/i, 1] || (text[/\A\d+/] unless hours)
    total = hours.to_f * 60 + mins.to_i
    total.round if total.positive?
  end

  def initialize(text)
    @text = text.to_s
  end

  def lines = @lines ||= join_wrapped(read)

  # Enough was found to build a recipe without asking the cook to sort the lines first: a title, some steps, and ingredients
  # (a single one is enough when the text had "Ingredients" and "Directions" headings to say so).
  def confident?
    roles = lines.map(&:role)
    roles.include?("title") && roles.include?("step") && roles.count("ingredient") >= (@explicit ? 1 : 2)
  end

  private
    def read
      rows = @text.lines.map { |raw| clean(raw) }.compact_blank.grep_v(/\A\d{1,3}\z/) # lone numbers are page or step numbers
      @explicit = rows.any? { |row| row.match?(INGREDIENTS_HEADER) || row.match?(STEPS_HEADER) }
      @intro_is_noise = rows.any? { |row| ingredient_like?(row) }
      @section = nil
      @titled = false

      rows.filter_map { |row| classify(row) }
    end

    def clean(raw) = raw.tr("   ", " ").gsub(/\s+/, " ").strip.sub(BULLET, "").strip

    def classify(row)
      if row.match?(INGREDIENTS_HEADER) then @section = :ingredient and return nil
      elsif row.match?(STEPS_HEADER) then @section = :step and return nil
      elsif row.match?(SKIPPED_HEADER) then @section = :skip and return nil
      end
      return Line.new(row, "meta") if meta?(row)

      if @section.nil? && !@titled && title_like?(row)
        @titled = true
        return Line.new(row, "title")
      end

      case @section
      when :ingredient then ingredient_context(row)
      when :step then step(row)
      when :skip then Line.new(row, "skip")
      else unlabeled(row)
      end
    end

    # Under an Ingredients heading everything is an ingredient. With no heading at all, the section is a guess, so a line that
    # doesn't look like an ingredient is taken to be where the steps begin.
    def ingredient_context(row)
      if heading_like?(row) then Line.new(row.delete_suffix(":").strip, "heading")
      elsif numbered?(row) then (@section = :step) && step(row)
      elsif @explicit || ingredient_like?(row) || short_plain?(row) then Line.new(row, "ingredient")
      else (@section = :step) && step(row)
      end
    end

    def unlabeled(row)
      if numbered?(row) then (@section = :step) && step(row)
      elsif ingredient_like?(row) then (@section = :ingredient) && Line.new(row, "ingredient")
      elsif !@intro_is_noise then (@section = :step) && step(row) # no ingredients anywhere: all of it is method
      else Line.new(row, "skip") # a blurb before the ingredients
      end
    end

    def step(row) = Line.new(row.sub(NUMBERED, ""), "step")

    def meta?(row) = row.match?(SERVINGS) || row.match?(PREP) || row.match?(COOK) || row.match?(TOTAL)
    def numbered?(row) = row.match?(NUMBERED)
    def words(row) = row.split.size

    def ingredient_like?(row)
      return false if numbered?(row) || !row.match?(QUANTITY)

      words(row) <= 14 && !(row.end_with?(".") && words(row) > 6)
    end

    def short_plain?(row) = words(row) <= 5 && !row.end_with?(".")

    def title_like?(row)
      row.length <= 100 && words(row) <= 12 && !row.end_with?(".", ":") && !ingredient_like?(row) && !numbered?(row)
    end

    # "For the sauce:" or "SAUCE": a short line, no numbers, that names a group of ingredients.
    def heading_like?(row)
      return false if row.match?(/\d/) || words(row) > 6

      row.end_with?(":") || (row.match?(/[A-Z]/) && row == row.upcase && row.length <= 30)
    end

    # A scanned page breaks lines wherever the print does: glue a continuation back onto the line it belongs to. Only a line that
    # runs most of the way across the page can have wrapped, so short lines ("bread", "butter") are left alone.
    def join_wrapped(lines)
      lines.each_with_object([]) do |line, joined|
        previous = joined.last
        if previous && previous.role == line.role && continues?(previous.text, line)
          joined[-1] = Line.new("#{previous.text} #{line.text}", line.role)
        else
          joined << line
        end
      end
    end

    def continues?(previous, line)
      case line.role
      when "step" then previous.length >= WRAP_WIDTH && line.text.match?(/\A[a-z0-9(]/) && !previous.match?(/[.!?:]["')]?\z/)
      when "ingredient" then line.text.match?(/\A[a-z)(]/) && (previous.end_with?(",") || previous.count("(") > previous.count(")"))
      else false
      end
    end
end
