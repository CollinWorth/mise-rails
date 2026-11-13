import { Controller } from "@hotwired/stimulus"

// A floating menu: opens from its button, closes on Esc, on a click elsewhere, and after choosing an item.
export default class extends Controller {
  static targets = [ "button", "panel" ]

  toggle() {
    this.panelTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.panelTarget.hidden = false
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.panelTarget.querySelector("a, button")?.focus()
  }

  close() {
    if (this.panelTarget.hidden) return
    this.panelTarget.hidden = true
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  clickAway(event) {
    if (!this.element.contains(event.target)) this.close()
  }
}
