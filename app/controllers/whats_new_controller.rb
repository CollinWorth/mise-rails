class WhatsNewController < ApplicationController
  # The sheet that opens by itself while there is something unread; "all" (from the account page) replays everything.
  def show
    entries = params[:all].present? ? WhatsNew.entries : WhatsNew.unseen(Current.user)
    render_sheet(fallback: recipes_path) { Views::WhatsNew::Show.new(entries: entries.presence || WhatsNew.entries) }
  end

  def update
    Current.user.saw_whats_new!
    head :no_content
  end
end
