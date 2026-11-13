import { Controller } from "@hotwired/stimulus"

// Shows the chosen photo in its tile before saving, and lets one be dropped onto the tile.
export default class extends Controller {
  static targets = [ "input", "tile", "preview", "empty" ]

  show() {
    const file = this.inputTarget.files[0]
    if (!file || !file.type.startsWith("image/")) return

    this.previewTarget.src = URL.createObjectURL(file)
    this.previewTarget.hidden = false
    this.emptyTarget.hidden = true
  }

  over(event) {
    event.preventDefault()
    this.tileTarget.dataset.over = ""
  }

  leave() {
    delete this.tileTarget.dataset.over
  }

  drop(event) {
    event.preventDefault()
    this.leave()
    if (!event.dataTransfer.files.length) return

    this.inputTarget.files = event.dataTransfer.files
    this.show()
  }
}
