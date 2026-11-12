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

  // Return in a row goes to the next row, adding a new one after the last.
  enter(event) {
    event.preventDefault()
    const rows = this.itemTargets.filter((item) => !item.hidden)
    let next = rows[rows.indexOf(event.target.closest("[data-nested-form-target='item']")) + 1]
    if (!next) {
      this.add()
      next = this.itemTargets.at(-1)
    }
    next.querySelector("input:not([type=hidden])").focus()
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
