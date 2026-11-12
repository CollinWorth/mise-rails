import { Controller } from "@hotwired/stimulus"

// Fades a flash message out after a few seconds, or on tap.
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.dismiss(), 4000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("opacity-0")
    setTimeout(() => this.element.remove(), 300)
  }
}
