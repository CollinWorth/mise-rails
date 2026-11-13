# A round badge with a person's initial.
class Components::Avatar < Components::Base
  def initialize(name:, size: "size-8 text-sm")
    @name = name
    @size = size
  end

  def view_template
    span(class: [ "inline-flex shrink-0 items-center justify-center rounded-full bg-primary font-semibold text-primary-foreground", @size ], aria_hidden: "true") { @name.to_s.strip[0].to_s.upcase }
  end
end
