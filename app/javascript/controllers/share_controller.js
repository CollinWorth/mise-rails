import { Controller } from "@hotwired/stimulus"

// Share a link: the phone's share sheet where there is one, otherwise (a computer) the link is copied and a small message says so.
export default class extends Controller {
  static values = { title: String, url: String }

  async share() {
    try {
      if (navigator.share) {
        await navigator.share({ title: this.titleValue, url: this.urlValue })
      } else {
        await navigator.clipboard.writeText(this.urlValue)
        this.say("Link copied")
      }
    } catch {
      // dismissed by the user, or the browser would not let the page copy
    }
  }

  say(message) {
    const note = document.createElement("div")
    note.setAttribute("role", "status")
    note.className = "fixed inset-x-4 bottom-[calc(env(safe-area-inset-bottom)+5.5rem)] z-50 mx-auto max-w-sm rounded-lg border bg-background px-4 py-3 text-sm text-foreground shadow-lg transition-opacity duration-300 md:inset-x-auto md:bottom-auto md:right-4 md:top-4"
    note.textContent = message
    document.body.append(note)
    setTimeout(() => note.classList.add("opacity-0"), 2200)
    setTimeout(() => note.remove(), 2600)
  }
}
