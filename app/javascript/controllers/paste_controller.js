import { Controller } from "@hotwired/stimulus"

// The import box: a Paste button where the browser lets a page read the clipboard, and focus on a computer (on a phone
// that would pop the keyboard up over the instructions).
export default class extends Controller {
  static targets = ["field", "button"]

  connect() {
    if (!navigator.clipboard?.readText) this.buttonTarget.hidden = true
    if (matchMedia("(min-width: 768px)").matches) this.fieldTarget.focus()
  }

  async paste() {
    try {
      const text = await navigator.clipboard.readText()
      if (text) this.fieldTarget.value = text
    } catch {
      // Permission was refused; the cook can still paste into the box themselves.
    }
    this.fieldTarget.focus()
  }
}
