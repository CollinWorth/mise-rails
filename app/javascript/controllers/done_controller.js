import { Controller } from "@hotwired/stimulus"

// Tap a cook-mode step to dim it as done; tap again to undo.
export default class extends Controller {
  toggle() {
    const done = this.element.classList.toggle("opacity-40")
    this.element.setAttribute("aria-pressed", done)
  }
}
