# Where a grocery item came from: which recipe or meal, and how much each one needed.
class Views::GroceryLists::Items::Show < Views::Base
  def initialize(item:)
    @item = item
  end

  def view_template
    Sheet(title: @item.name.capitalize) do
      Stack do
        Text { "On your list: #{@item.to_line}" }
        @item.sources.any? ? sources : Text { "Added by hand, so there's no recipe behind it." }
        SheetLink(href: edit_grocery_list_item_path(@item), variant: :outline) { "Edit item" }
      end
    end
  end

  private
    def sources
      Stack(gap: :sm) do
        Heading(level: 4) { "From" }
        @item.sources.each do |source|
          Card do
            CardContent do
              Row(justify: :between) do
                Stack(gap: :sm) do
                  recipe_name(source)
                  Text(class: "text-xs text-muted-foreground") { "Planned for #{source.planned_on.strftime('%A, %b %-d')}" } if source.planned_on
                end
                Text { source.to_line(@item.name) }
              end
            end
          end
        end
      end
    end

    def recipe_name(source)
      source.recipe ? TextLink(href: recipe_path(source.recipe), data: { turbo_frame: "_top" }) { source.recipe_name } : Text { "#{source.recipe_name} (deleted)" }
    end
end
