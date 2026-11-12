import { Controller } from "@hotwired/stimulus"

// Adds and removes rows of a nested form (ingredients and section headings).
export default class extends Controller {
  static targets = ["list", "template", "sectionTemplate", "item", "destroy"]

  add() {
    this.insert(this.templateTarget)
  }

  // A heading row such as "For the sauce".
  addSection() {
    this.insert(this.sectionTemplateTarget)
  }

  insert(template) {
    const index = this.itemTargets.length + Date.now()
    this.listTarget.insertAdjacentHTML("beforeend", template.innerHTML.replaceAll("NEW_RECORD", index))
  }

  remove(event) {
    const item = event.target.closest("[data-nested-form-target='item']")
    const destroy = item.querySelector("[data-nested-form-target='destroy']")
    if (item.querySelector("input[name$='[id]']")) {
      destroy.value = "1"
      item.hidden = true
    } else {
      item.remove()
    }
  }
}
