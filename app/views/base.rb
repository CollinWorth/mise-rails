# frozen_string_literal: true

class Views::Base < Components::Base
  # Turbo Frame requests (the meal-plan sheet) only need the fragment, not the page chrome.
  def around_template
    return super if view_context.request.headers["Turbo-Frame"].present?

    render(Components::Layouts::Application.new) { super }
  end

  def cache_store = Rails.cache
end
