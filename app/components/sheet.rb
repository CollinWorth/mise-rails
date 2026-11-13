# A full-screen sheet that slides up over the page. It renders into the layout's
# `modal` Turbo Frame, so open it with a SheetLink, and give forms inside it `top: true`
# so submitting them updates the page behind. The sheet controller handles closing and
# the slide-down after a form is submitted.
class Components::Sheet < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template(&)
    turbo_frame(id: "modal") do
      div(data: { controller: "sheet", action: "turbo:submit-start->sheet#closing keydown.esc@window->sheet#dismiss" },
          class: "fixed inset-0 z-50 flex flex-col bg-background pt-[env(safe-area-inset-top)] pb-[env(safe-area-inset-bottom)] animate-in slide-in-from-bottom duration-200") do
        div(class: "flex items-center justify-between border-b p-4") do
          Heading(level: 3) { @title }
          Button(type: :button, variant: :ghost, data: { action: "sheet#dismiss" }) { "Close" }
        end
        div(class: "flex-1 overflow-y-auto overscroll-contain p-4", &)
      end
    end
  end
end
