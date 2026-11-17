import { Controller } from "@hotwired/stimulus"

// Steps through the "What's new" cards one at a time. Opening the sheet marks everything as read on the server, so it
// never comes back however it is closed (a skip, a swipe away, or reading to the end).
export default class extends Controller {
  static targets = [ "card", "controls", "back", "next", "done", "count" ]
  static values = { seenUrl: String }

  connect() {
    this.index = 0
    this.controlsTarget.hidden = false
    this.render()
    this.markSeen()
  }

  next() { this.go(1) }
  back() { this.go(-1) }

  go(step) {
    this.index = Math.min(Math.max(this.index + step, 0), this.cardTargets.length - 1)
    this.render()
  }

  render() {
    const last = this.cardTargets.length - 1
    this.cardTargets.forEach((card, i) => card.hidden = i !== this.index)
    this.backTarget.hidden = this.index === 0
    this.nextTarget.hidden = this.index === last
    this.doneTarget.hidden = this.index !== last
    this.countTarget.textContent = last > 0 ? `${this.index + 1} of ${last + 1}` : ""
  }

  markSeen() {
    const token = document.querySelector("meta[name=csrf-token]")?.content
    fetch(this.seenUrlValue, { method: "PATCH", headers: { "X-CSRF-Token": token }, credentials: "same-origin", keepalive: true })
  }
}
