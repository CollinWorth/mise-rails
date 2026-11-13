class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  layout false # views wrap themselves in Components::Layouts::Application
  allow_browser versions: :modern
  stale_when_importmap_changes
  before_action { Current.theme = cookies[:theme] }

  rescue_from ActiveRecord::RecordInvalid do |error|
    redirect_back_or_to root_path, alert: error.record.errors.full_messages.to_sentence, status: :see_other
  end

  private
    # A date from the query string, or nil if it's missing or not a date.
    def date_param(key = :date)
      Date.iso8601(params[key]) if params[key].present?
    rescue Date::Error
      nil
    end

    # Sheets (see Components::Sheet) load into the layout's `modal` Turbo Frame.
    # Opened any other way, they send you to the page they belong over instead.
    def render_sheet(fallback:)
      turbo_frame_request? ? render(yield) : redirect_to(fallback)
    end
end
