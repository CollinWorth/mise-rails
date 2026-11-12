import { Controller } from "@hotwired/stimulus"

// Opens the phone's share sheet. The button stays hidden where sharing isn't supported.
export default class extends Controller {
  static values = { title: String, url: String }

  connect() {
    this.element.hidden = !navigator.share
  }

  async share() {
    try {
      await navigator.share({ title: this.titleValue, url: this.urlValue })
    } catch {
      // dismissed by the user
    }
  }
}
