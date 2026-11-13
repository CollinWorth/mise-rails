# frozen_string_literal: true

class Views::Base < Components::Base
  # Turbo Frame requests (the meal-plan sheet) only need the fragment, not the page chrome.
  def around_template
    return super if view_context.request.headers["Turbo-Frame"].present?

    render(Components::Layouts::Application.new(bleed: bleed?, quiet_nav: quiet_nav?)) { super }
  end

  # Pages that draw their own full-width sections skip the layout's centered column.
  def bleed? = false

  # The front door keeps the top bar to just the brand, since the page itself says how to get in.
  def quiet_nav? = false

  def cache_store = Rails.cache
end
