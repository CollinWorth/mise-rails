# A small label tinted in one of the theme's three colors (times and servings, cuisine, "Today"...), built on the library's Badge.
class Components::Tag < Components::Base
  TONES = {
    primary: "border-primary/30 bg-primary/10 text-primary",
    secondary: "border-brand-2/30 bg-brand-2/10 text-brand-2",
    tertiary: "border-brand-3/30 bg-brand-3/10 text-brand-3"
  }.freeze

  def initialize(tone: :secondary, **attrs)
    @tone = tone
    @attrs = attrs
  end

  def view_template(&) = Badge(variant: :outline, class: [ TONES.fetch(@tone), @attrs.delete(:class) ], **@attrs, &)
end
