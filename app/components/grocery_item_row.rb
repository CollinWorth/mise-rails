# One grocery list line: tap anywhere on the name to tick it off, ⓘ for where it came from, ✎ to edit.
# It lives in its own Turbo Frame so editing can happen in place on a desktop (see GroceryItemEditRow and edit_link_controller.js).
class Components::GroceryItemRow < Components::Base
  def initialize(item:)
    @item = item
  end

  def view_template
    turbo_frame(id: "item_#{@item.id}") do
      div(class: "group flex items-center gap-1") do
        toggle
        sources_link if @item.sources.any?
        edit_link
      end
    end
  end

  private
    def toggle
      ActionForm(action: grocery_list_item_path(@item), method: :patch, top: true, class: "min-w-0 flex-1") do
        input(type: :hidden, name: "item[checked]", value: @item.checked? ? "0" : "1")
        Button(type: :submit, variant: :ghost, class: "h-auto w-full justify-start gap-3 whitespace-normal px-2 py-2.5 text-left font-normal") do
          check_circle
          span(class: [ "min-w-0 flex-1 truncate text-base font-medium", ("text-muted-foreground line-through" if @item.checked?) ]) { @item.name }
          span(class: "shrink-0 text-sm text-muted-foreground") { @item.amount_text }
        end
      end
    end

    def check_circle
      span(class: [ "flex size-5 shrink-0 items-center justify-center rounded-full border-2 transition", (@item.checked? ? "border-primary bg-primary text-primary-foreground" : "border-muted-foreground/40") ]) do
        Icon(:check, class: "size-3") if @item.checked?
      end
    end

    def sources_link
      SheetLink(href: grocery_list_item_path(@item), variant: :ghost, size: :sm, class: "size-9 p-0 text-muted-foreground", aria: { label: "Where this is from" }) { Icon(:info, class: "size-4") }
    end

    # Where there is a mouse the pencil appears on hover (and on keyboard focus); on touch screens it is always there.
    def edit_link
      Link(href: edit_grocery_list_item_path(@item), variant: :ghost, size: :sm, aria: { label: "Edit #{@item.name}" },
           class: "size-9 p-0 text-muted-foreground [@media(hover:hover)]:opacity-0 [@media(hover:hover)]:group-hover:opacity-100 focus-visible:opacity-100",
           data: { controller: "edit-link", action: "click->edit-link#choose" }) { Icon(:pencil, class: "size-4") }
    end
end
