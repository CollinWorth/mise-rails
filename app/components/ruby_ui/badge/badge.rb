# frozen_string_literal: true

module RubyUI
  class Badge < Base
    SIZES = {
      sm: "px-1.5 py-0.5 text-xs",
      md: "px-2 py-1 text-xs",
      lg: "px-3 py-1 text-sm"
    }

    COLORS = {
      primary: "text-primary bg-primary/5 ring-primary/20",
      secondary: "text-secondary bg-secondary/10 ring-secondary/20",
      outline: "text-foreground bg-background ring-border",
      destructive: "text-destructive bg-destructive/10 ring-destructive/20",
      success: "text-success bg-success/10 ring-success/20",
      warning: "text-warning bg-warning/10 ring-warning/20"
    }

    def initialize(variant: :primary, size: :md, **args)
      @variant = variant
      @size = size
      super(**args)
    end

    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        class: ["inline-flex items-center rounded-md font-medium ring-1 ring-inset", SIZES[@size], COLORS[@variant]]
      }
    end
  end
end
