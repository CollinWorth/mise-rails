# Shared looks for the fridge-door landing page (Components::Fridge::*). Written out as whole class names so Tailwind sees them;
# shadows are made from the theme's text color, so they follow the theme like everything else.
module Components::Fridge
  extend Phlex::Kit

  HAND = "font-[Bradley_Hand,'Segoe_Print','Chalkboard_SE',cursive]"
  MAGNET_SHADOW = "shadow-[0_2px_0_color-mix(in_oklab,var(--foreground)_18%,transparent),0_6px_10px_-4px_color-mix(in_oklab,var(--foreground)_40%,transparent)]"
  NOTE_SHADOW = "shadow-[0_8px_14px_-6px_color-mix(in_oklab,var(--foreground)_45%,transparent)]"
  # The enamel: a soft vertical gradient with fine brushed lines, and a chrome finish for handles and the nameplate.
  BODY = "bg-gradient-to-b from-card via-card to-muted shadow-[0_18px_30px_-12px_color-mix(in_oklab,var(--foreground)_45%,transparent),inset_-6px_0_10px_-6px_color-mix(in_oklab,var(--foreground)_25%,transparent)]"
  BRUSHED = "bg-[repeating-linear-gradient(90deg,color-mix(in_oklab,var(--foreground)_3%,transparent)_0_1px,transparent_1px_5px)]"
  CHROME = "border bg-gradient-to-r from-muted via-background to-muted shadow-[0_2px_4px_color-mix(in_oklab,var(--foreground)_30%,transparent)]"
  PHOTO_SHADOW = "shadow-[0_10px_16px_-6px_color-mix(in_oklab,var(--foreground)_50%,transparent)]"
end
