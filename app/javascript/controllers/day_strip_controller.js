import { Controller } from "@hotwired/stimulus"

// Scrolls to the tapped day itself. Left to the browser, the #day links count as a Turbo visit to the same page, which
// restores the old scroll position instead of moving.
export default class extends Controller {
  jump(event) {
    const day = document.getElementById(event.currentTarget.hash.slice(1))
    if (!day) return

    event.preventDefault()
    day.scrollIntoView({ block: "start", behavior: matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth" })
  }
}
