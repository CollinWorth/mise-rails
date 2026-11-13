import { Controller } from "@hotwired/stimulus"

// "Make it yours" on the landing page: trying a theme restyles the whole page. Nothing is saved; it is a preview
// that lasts until the page is left (signing up lets you keep one).
export default class extends Controller {
  static targets = ["tile"]

  choose(event) {
    const tile = event.currentTarget
    const root = document.documentElement
    root.dataset.appearance = "preview" // stops "match my device" from switching it back
    root.dataset.palette = tile.dataset.palette
    root.classList.toggle("dark", tile.dataset.mode === "dark")
    this.tileTargets.forEach((other) => other.setAttribute("aria-pressed", other === tile))
  }
}
