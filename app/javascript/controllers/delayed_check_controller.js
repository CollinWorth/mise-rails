import { Controller } from "@hotwired/stimulus"

// Ticking a grocery line waits a beat while its circle fills in, so a stray tap can be undone by tapping again.
export default class extends Controller {
  static values = { delay: { type: Number, default: 700 } }

  submit(event) {
    if (this.sending) return

    event.preventDefault()
    if (this.timer) return this.cancel()

    this.element.style.setProperty("--fill-time", `${this.delayValue}ms`)
    this.element.dataset.filling = ""
    this.timer = setTimeout(() => {
      this.sending = true
      this.element.requestSubmit()
    }, this.delayValue)
  }

  cancel() {
    clearTimeout(this.timer)
    this.timer = null
    delete this.element.dataset.filling
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
