import { Controller } from "@hotwired/stimulus"

// Fades a section in as it scrolls into view. Without JavaScript (or when the page is already in view) it simply shows.
export default class extends Controller {
  connect() {
    if (!("IntersectionObserver" in window)) return

    this.element.dataset.reveal = "hidden"
    this.observer = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) {
        this.element.dataset.reveal = "shown"
        this.observer.disconnect()
      }
    }, { threshold: 0.15 })
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
