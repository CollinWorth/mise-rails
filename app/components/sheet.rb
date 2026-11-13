# A sheet that slides up full-screen on phones and opens as a centered dialog from `md` up. It renders into the layout's
# `modal` Turbo Frame, so open it with a SheetLink, and give forms inside it `top: true`
# so submitting them updates the page behind. The sheet controller handles closing and
# the slide-down after a form is submitted.
class Components::Sheet < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template(&)
    turbo_frame(id: "modal") do
      div(data: { controller: "sheet", action: "turbo:submit-start->sheet#closing keydown.esc@window->sheet#dismiss click->sheet#backdrop" },
          class: "fixed inset-0 z-50 animate-in fade-in duration-200 md:flex md:items-center md:justify-center md:bg-black/50 md:p-6") do
        div(data: { sheet_target: "panel" },
            class: "flex h-full flex-col bg-background pt-[env(safe-area-inset-top)] pb-[env(safe-area-inset-bottom)] animate-in duration-200 max-md:slide-in-from-bottom md:zoom-in-95 " \
                   "md:h-auto md:max-h-[85vh] md:w-full md:max-w-xl md:rounded-xl md:border md:pt-0 md:pb-0 md:shadow-2xl") do
          div(class: "flex items-center justify-between border-b p-4") do
            Heading(level: 3) { @title }
            Button(type: :button, variant: :ghost, data: { action: "sheet#dismiss" }) { "Close" }
          end
          div(class: "flex-1 overflow-y-auto overscroll-contain p-4 md:p-6", &)
        end
      end
    end
  end
end
