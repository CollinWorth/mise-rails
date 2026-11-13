import { Controller } from "@hotwired/stimulus"

// The "How I read it" screen (Components::LineSorter). Each row holds a line of the imported text and its role in hidden
// fields, so submitting the form sends exactly what is on screen. Tapping a row opens a tray to change that line; two
// shortcuts fix the common mistake of a wrong boundary between ingredients and steps in one tap.
export default class extends Controller {
  static targets = ["row", "count"]

  connect() {
    this.recount()
  }

  toggle(event) {
    const tray = this.rowOf(event.currentTarget).querySelector("[data-tray]")
    const opening = tray.hidden
    this.closeAll()
    tray.hidden = !opening
    event.currentTarget.setAttribute("aria-expanded", String(opening))
  }

  set(event) {
    this.assign(this.rowOf(event.currentTarget), event.params.role)
    this.closeAll()
  }

  // This line and every ingredient below it become steps.
  below(event) {
    const row = this.rowOf(event.currentTarget)
    this.rowTargets.slice(this.rowTargets.indexOf(row)).forEach((other) => {
      if (other === row || other.dataset.role === "ingredient") this.assign(other, "step")
    })
    this.closeAll()
  }

  // This line and every step above it become ingredients.
  above(event) {
    const row = this.rowOf(event.currentTarget)
    this.rowTargets.slice(0, this.rowTargets.indexOf(row) + 1).forEach((other) => {
      if (other === row || other.dataset.role === "step") this.assign(other, "ingredient")
    })
    this.closeAll()
  }

  // Glue this line onto the one above (text that was wrapped onto two lines).
  join(event) {
    const row = this.rowOf(event.currentTarget)
    const previous = this.rowTargets[this.rowTargets.indexOf(row) - 1]
    if (!previous) return

    const text = `${this.textOf(previous)} ${this.textOf(row)}`.trim()
    previous.querySelector("[data-text-input]").value = text
    previous.querySelector("[data-text]").textContent = text
    row.remove()
    this.closeAll()
    this.recount()
  }

  assign(row, role) {
    if (role === "title") this.rowTargets.filter((other) => other !== row && other.dataset.role === "title").forEach((other) => this.assign(other, "skip"))
    row.dataset.role = role
    row.querySelector("[data-role-input]").value = role
    this.recount()
  }

  closeAll() {
    this.rowTargets.forEach((row) => {
      row.querySelector("[data-tray]").hidden = true
      row.querySelector("button[aria-expanded]").setAttribute("aria-expanded", "false")
    })
  }

  recount() {
    this.countTargets.forEach((target) => {
      target.textContent = this.rowTargets.filter((row) => row.dataset.role === target.dataset.role).length
    })
  }

  rowOf(element) {
    return element.closest("[data-line-sorter-target=row]")
  }

  textOf(row) {
    return row.querySelector("[data-text-input]").value
  }
}
