# Flash messages shown as toasts that dismiss themselves. On a phone they sit just above the tab bar, so they never cover the
# account button at the top; from md up they drop in at the top right.
class Components::FlashMessages < Components::Base
  def initialize(flash:)
    @flash = flash
  end

  def view_template
    return if @flash.none?

    div(class: "fixed inset-x-4 bottom-[calc(env(safe-area-inset-bottom)+5.5rem)] z-50 flex flex-col gap-2 md:inset-x-auto md:bottom-auto md:right-4 md:top-[calc(env(safe-area-inset-top)+0.75rem)] md:w-96") do
      @flash.each do |type, message|
        div(data: { controller: "toast", action: "click->toast#dismiss" }, class: "shadow-lg transition-opacity duration-300") do
          Alert(variant: type.to_s == "alert" ? :destructive : :default, role: (type.to_s == "alert" ? "alert" : "status")) { AlertDescription { message } }
        end
      end
    end
  end
end
