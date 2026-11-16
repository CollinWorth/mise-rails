# For the endpoints the iOS Shortcuts call: signs in with the key in an Authorization header ("Bearer …", made on the profile
# page) instead of a session. Answers are JSON with a `message` the Shortcut can speak or show.
module ShortcutAuthenticated
  extend ActiveSupport::Concern

  included do
    allow_unauthenticated_access
    skip_forgery_protection
    before_action :authenticate_shortcut
    rate_limit to: 60, within: 1.minute, with: -> { render json: { message: "Too many tries. Wait a minute." }, status: :too_many_requests }
  end

  private
    def authenticate_shortcut
      @user = User.find_by_shortcut_token(request.authorization.to_s[/\ABearer (\S+)\z/, 1])
      render json: { message: "That key isn't valid. Make a new one in Mise." }, status: :unauthorized unless @user
    end
end
