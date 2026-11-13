# "How I read it": every line of the imported text with the role it was given (title, details, ingredient, section, step, or
# skipped). Tap a line to correct it; the tray offers the roles, plus shortcuts for the usual mistakes ("everything from here
# down is steps", "join with the line above"). See line_sorter_controller.js. Submitting sends the lines with their roles.
class Components::LineSorter < Components::Base
  LABELS = { "title" => "Title", "meta" => "Detail", "ingredient" => "Ingredient", "heading" => "Section", "step" => "Step", "skip" => "Skip" }.freeze
  # Written out in full (not built from the role name) so Tailwind can see every class. A row shows only the chip of its role.
  CHIPS = {
    "title" => "group-data-[role=title]:inline-block bg-foreground/10 text-foreground",
    "meta" => "group-data-[role=meta]:inline-block bg-muted text-muted-foreground",
    "ingredient" => "group-data-[role=ingredient]:inline-block bg-brand-2/15 text-brand-2",
    "heading" => "group-data-[role=heading]:inline-block bg-brand-3/15 text-brand-3",
    "step" => "group-data-[role=step]:inline-block bg-primary/15 text-primary",
    "skip" => "group-data-[role=skip]:inline-block bg-muted text-muted-foreground"
  }.freeze
  # The roles you can give a line (a "Detail" is only ever a guess).
  CHOICES = %w[title ingredient heading step skip].freeze

  def initialize(lines:)
    @lines = lines
  end

  def view_template(&actions)
    ActionForm(action: recipes_import_path, data: { controller: "line-sorter" }) do
      Stack do
        counts
        Stack(gap: :sm) { @lines.each_with_index { |line, index| row(line, index) } }
        Row(gap: :sm, &actions)
      end
    end
  end

  private
    def counts
      Row(gap: :sm, class: "text-sm text-muted-foreground", aria: { live: "polite" }) do
        count("ingredient", "Ingredients")
        plain "·"
        count("step", "Steps")
      end
    end

    def count(role, label)
      span { plain "#{label}: "; span(data: { line_sorter_target: "count", role: }) { "0" } }
    end

    def row(line, index)
      div(data: { line_sorter_target: "row", role: line.role },
          class: "group rounded-lg border border-l-4 bg-card data-[role=ingredient]:border-l-brand-2 data-[role=step]:border-l-primary data-[role=heading]:border-l-brand-3 " \
                 "data-[role=title]:border-l-foreground data-[role=meta]:border-l-muted-foreground/40 data-[role=skip]:border-l-transparent data-[role=skip]:opacity-60") do
        input(type: :hidden, name: "lines[#{index}][text]", value: line.text, data: { text_input: true })
        input(type: :hidden, name: "lines[#{index}][role]", value: line.role, data: { role_input: true })
        button(type: :button, aria: { expanded: "false", label: "Change #{line.text.truncate(40)}" }, data: { action: "line-sorter#toggle" }, class: "flex w-full items-start gap-3 p-3 text-left") do
          span(class: "w-[5.5rem] shrink-0") { LABELS.each { |role, label| chip(role, label) } }
          span(data: { text: true }, class: "min-w-0 flex-1 break-words text-sm group-data-[role=skip]:line-through") { line.text }
        end
        tray(index)
      end
    end

    def chip(role, label)
      span(class: [ "hidden rounded-full px-2 py-0.5 text-xs font-medium", CHIPS.fetch(role) ]) { label }
    end

    def tray(index)
      div(hidden: true, data: { tray: true }, class: "flex flex-col gap-2 border-t p-3") do
        Text(size: "2", class: "text-muted-foreground") { "This line is a…" }
        Row(gap: :sm) do
          CHOICES.each { |role| Button(type: :button, variant: :outline, size: :sm, data: { action: "line-sorter#set", line_sorter_role_param: role }) { LABELS.fetch(role) } }
        end
        Row(gap: :sm) do
          Button(type: :button, variant: :ghost, size: :sm, data: { action: "line-sorter#below" }) { "From here down are steps" }
          Button(type: :button, variant: :ghost, size: :sm, data: { action: "line-sorter#above" }) { "From here up are ingredients" }
          Button(type: :button, variant: :ghost, size: :sm, data: { action: "line-sorter#join" }) { "Join with the line above" } if index.positive?
        end
      end
    end
end
