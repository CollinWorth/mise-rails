# A soft blurred blob of color that drifts slowly behind a section.
class Components::Landing::Glow < Components::Base
  def initialize(position:, delay: "0s", blur: "blur-3xl")
    @position = position
    @delay = delay
    @blur = blur
  end

  def view_template
    div(class: [ "drift-blob pointer-events-none absolute rounded-full", @blur, @position ], style: "--delay: #{@delay}", aria_hidden: "true")
  end
end
