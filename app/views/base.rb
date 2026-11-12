# frozen_string_literal: true

class Views::Base < Components::Base
  def around_template
    render(Components::Layouts::Application.new) { super }
  end

  def cache_store = Rails.cache
end
