import { Controller } from "@hotwired/stimulus"

// A sheet (full-screen on phones, a centered dialog on desktop): slides up on load,
// slides down on close, and after a submit holds Turbo's page refresh until it has left.
export default class extends Controller {
  static targets = [ "panel" ]

  connect() {
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }

  async dismiss() {
    await this.leave()
    this.element.closest("turbo-frame").replaceChildren()
  }

  // On desktop the dimmed area around the dialog closes it.
  backdrop(event) {
    if (event.target === this.element) this.dismiss()
  }

  // Search forms (GET) also bubble submit events; only a real submission closes the sheet.
  // A submit button marked data-keep-open (it updates the sheet in place) doesn't.
  closing(event) {
    if (event.target.method?.toLowerCase() !== "post") return
    if (event.detail.formSubmission.submitter?.dataset.keepOpen) return

    document.addEventListener("turbo:before-render", this.holdRender, { once: true })
  }

  holdRender = async (event) => {
    event.preventDefault()
    await this.leave()
    event.detail.resume()
  }

  leave() {
    return new Promise((resolve) => {
      this.element.classList.remove("animate-in", "fade-in")
      this.element.classList.add("animate-out", "fade-out")
      this.panelTarget.classList.remove("animate-in", "max-md:slide-in-from-bottom", "md:zoom-in-95")
      this.panelTarget.classList.add("animate-out", "max-md:slide-out-to-bottom", "md:zoom-out-95")
      this.element.addEventListener("animationend", resolve, { once: true })
      setTimeout(resolve, 400)
    })
  }
}
