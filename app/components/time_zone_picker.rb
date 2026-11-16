# The profile's time zone: follow the device (the default) or pin one. Saves by itself (autosubmit).
class Components::TimeZonePicker < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    ActionForm(action: profile_path, method: :patch, data: { controller: "autosubmit", action: "change->autosubmit#queue" }) do
      select(name: "user[time_zone]", aria_label: "Time zone", class: "w-full rounded-md border border-input bg-background px-3 py-2 text-sm") do
        option(value: "", selected: @user.time_zone.blank?) { "Match my device" }
        ActiveSupport::TimeZone.all.each do |zone|
          option(value: zone.name, selected: zone.name == @user.time_zone) { zone.to_s }
        end
      end
    end
  end
end
