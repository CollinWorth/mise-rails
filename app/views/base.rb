# frozen_string_literal: true

class Views::Base < Components::Base
  # Turbo Frame requests (the meal-plan sheet) only need the fragment, not the page chrome.
  def around_template
    return super if view_context.request.headers["Turbo-Frame"].present?

    render(Components::Layouts::Application.new(bleed: bleed?, quiet_nav: quiet_nav?, meta: page_meta)) { super }
  end

  # Pages that draw their own full-width sections skip the layout's centered column.
  def bleed? = false

  # What link previews and the tab title say about this page (see Components::Layouts::Application); nothing by default.
  def page_meta = nil

  # A path or route made absolute, for the parts of a preview that are fetched from outside.
  def absolute_url(path) = URI.join(view_context.request.base_url, path).to_s

  # The link-preview picture for a recipe, if it has a photo that may be shown: a JPEG made to size.
  def share_image(recipe)
    return unless recipe&.public? && recipe.image.attached? && recipe.image.variable?

    view_context.rails_storage_proxy_url(recipe.image.variant(:share))
  end

  # The front door keeps the top bar to just the brand, since the page itself says how to get in.
  def quiet_nav? = false

  def cache_store = Rails.cache
end
