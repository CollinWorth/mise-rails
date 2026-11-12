import { Controller } from "@hotwired/stimulus"

// Submits the form shortly after the user stops typing (search as you type).
export default class extends Controller {
  queue() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.requestSubmit(), 250)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
