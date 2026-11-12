class Current < ActiveSupport::CurrentAttributes
  attribute :session, :theme
  delegate :user, to: :session, allow_nil: true
end
