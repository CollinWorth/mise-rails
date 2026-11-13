# Shared looks for the fridge-door landing page (Components::Fridge::*). Written out as whole class names so Tailwind sees them;
# shadows are made from the theme's text color, so they follow the theme like everything else.
module Components::Fridge
  extend Phlex::Kit

  HAND = "font-[Bradley_Hand,'Segoe_Print','Chalkboard_SE',cursive]"
  MAGNET_SHADOW = "shadow-[0_2px_0_color-mix(in_oklab,var(--foreground)_18%,transparent),0_6px_10px_-4px_color-mix(in_oklab,var(--foreground)_40%,transparent)]"
  NOTE_SHADOW = "shadow-[0_8px_14px_-6px_color-mix(in_oklab,var(--foreground)_45%,transparent)]"
  PHOTO_SHADOW = "shadow-[0_10px_16px_-6px_color-mix(in_oklab,var(--foreground)_50%,transparent)]"
end
