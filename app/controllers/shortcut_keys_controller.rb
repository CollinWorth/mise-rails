# Makes the key the Siri Shortcut uses. It is shown once, right after it is made.
class ShortcutKeysController < ApplicationController
  def show
    key = flash[:shortcut_key]
    key ? render(Views::ShortcutKeys::Show.new(key:)) : redirect_to(profile_path)
  end

  def create
    flash[:shortcut_key] = Current.user.regenerate_shortcut_token
    redirect_to shortcut_key_path, status: :see_other
  end
end
