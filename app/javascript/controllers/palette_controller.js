import { Controller } from "@hotwired/stimulus"

// Shows the chosen color palette straight away; the form saves it a moment later.
export default class extends Controller {
  preview(event) {
    document.documentElement.dataset.palette = event.target.value
  }
}
