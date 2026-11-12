# Previous / next links for a Pagy object; renders nothing for a single page.
class Components::Pager < Components::Base
  def initialize(pagy:)
    @pagy = pagy
  end

  def view_template
    return if @pagy.last <= 1

    Pagination do
      PaginationContent do
        PaginationItem(href: @pagy.page_url(@pagy.previous)) { "Previous" } if @pagy.previous
        PaginationItem(active: true) { "#{@pagy.page} of #{@pagy.last}" }
        PaginationItem(href: @pagy.page_url(@pagy.next)) { "Next" } if @pagy.next
      end
    end
  end
end
