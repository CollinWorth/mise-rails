import { Controller } from "@hotwired/stimulus"

// Brings the element to the middle of the screen when it first appears.
export default class extends Controller {
  connect() {
    this.element.scrollIntoView({ block: "center" })
  }
}
