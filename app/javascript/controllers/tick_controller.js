import { Controller } from "@hotwired/stimulus"

// A list you can cross things off: each item toggles, and once all are done the note says so.
export default class extends Controller {
  static targets = ["item"]

  toggle(event) {
    const item = event.currentTarget
    item.setAttribute("aria-pressed", String(item.getAttribute("aria-pressed") !== "true"))
    const done = this.itemTargets.every((other) => other.getAttribute("aria-pressed") === "true")
    this.element.toggleAttribute("data-done", done)
  }
}
