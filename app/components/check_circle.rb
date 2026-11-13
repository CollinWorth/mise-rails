# The round tick mark of a grocery line. With `animate`, a ticked one pops in after `delay`.
class Components::CheckCircle < Components::Base
  def initialize(checked:, animate: false, delay: "0s")
    @checked = checked
    @animate = animate
    @delay = delay
  end

  def view_template
    span(class: [ "flex size-5 shrink-0 items-center justify-center rounded-full border-2 transition",
                  (@checked ? "border-brand-2 bg-brand-2 text-brand-2-foreground" : "border-muted-foreground/40"), ("tick-in" if @checked && @animate) ],
         style: ("--delay: #{@delay}" if @checked && @animate)) do
      Icon(:check, class: "size-3") if @checked
    end
  end
end
