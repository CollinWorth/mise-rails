import { Controller } from "@hotwired/stimulus"

// An edit link that edits in place on a desktop (loading into the Turbo Frame around it)
// and opens the full-screen sheet on a phone. Decided at click time, so rotating or resizing just works.
export default class extends Controller {
  choose() {
    const frame = this.element.closest("turbo-frame")
    const desktop = window.matchMedia("(min-width: 768px)").matches
    this.element.dataset.turboFrame = desktop && frame ? frame.id : "modal"
  }
}
