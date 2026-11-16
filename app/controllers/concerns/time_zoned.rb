# Days (today, this week, "cooked yesterday") are the cook's own: their chosen time zone, else the one their device
# reports (a cookie the layout sets), else the app's default.
module TimeZoned
  extend ActiveSupport::Concern

  included do
    around_action :use_time_zone
  end

  private
    def use_time_zone(&)
      Time.use_zone(time_zone_for_request, &)
    end

    def time_zone_for_request
      [ Current.user&.time_zone, cookies[:time_zone] ].lazy.filter_map { |name| ActiveSupport::TimeZone[name] if name.present? }.first || Time.zone
    end
end
