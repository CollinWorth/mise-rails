# Flash messages shown as toasts that dismiss themselves.
class Components::FlashMessages < Components::Base
  def initialize(flash:)
    @flash = flash
  end

  def view_template
    return if @flash.none?

    div(class: "fixed inset-x-4 top-[calc(env(safe-area-inset-top)+0.75rem)] z-50 flex flex-col gap-2 md:left-auto md:w-96") do
      @flash.each do |type, message|
        div(data: { controller: "toast", action: "click->toast#dismiss" }, class: "shadow-lg transition-opacity duration-300") do
          Alert(variant: type.to_s == "alert" ? :destructive : :default) { AlertDescription { message } }
        end
      end
    end
  end
end
