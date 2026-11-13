import { Controller } from "@hotwired/stimulus"

// A full-screen sheet: slides up on load, slides down on close, and after a
// submit holds Turbo's page refresh until the slide-down has finished.
export default class extends Controller {
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
      this.element.classList.remove("animate-in", "slide-in-from-bottom")
      this.element.classList.add("animate-out", "slide-out-to-bottom", "fade-out")
      this.element.addEventListener("animationend", resolve, { once: true })
      setTimeout(resolve, 400)
    })
  }
}
