import { Controller } from "@hotwired/stimulus"

const ROW = "[data-nested-form-target='item']"
const FIELD = "input:not([type=hidden])"

// The ingredient list of the recipe form: add, remove and reorder rows (ingredients and section headings).
// A section heading takes the rows under it along when it moves, and can only land between groups, never inside one
// or above the loose rows at the top (which would become part of it).
// Each row's position field is kept in step with the order on screen, so saving stores that order.
export default class extends Controller {
  static targets = ["list", "template", "sectionTemplate", "item", "destroy", "position"]

  connect() {
    this.renumber()
  }

  add() {
    this.insert(this.templateTarget).querySelector(FIELD).focus()
  }

  // A heading row such as "For the sauce".
  addSection() {
    this.insert(this.sectionTemplateTarget).querySelector(FIELD).focus()
  }

  // Return in a row goes to the next row, adding a new one below when it was the last.
  enter(event) {
    event.preventDefault()
    const row = event.target.closest(ROW)
    const next = this.sibling(row, 1) || this.insert(this.templateTarget, row)
    next.querySelector(FIELD).focus()
  }

  insert(template, after = null) {
    const key = Date.now() + this.itemTargets.length
    const html = template.innerHTML.replaceAll("NEW_RECORD", key)
    after ? after.insertAdjacentHTML("afterend", html) : this.listTarget.insertAdjacentHTML("beforeend", html)
    this.renumber()
    return after ? after.nextElementSibling : this.listTarget.lastElementChild
  }

  remove(event) {
    const item = event.target.closest(ROW)
    const destroy = item.querySelector("[data-nested-form-target='destroy']")
    if (item.querySelector("input[name$='[id]']")) {
      destroy.value = "1"
      item.hidden = true
    } else {
      item.remove()
    }
    this.renumber()
  }

  // --- reordering ---

  // Dragging a heading collapses its rows out of sight so it travels as one small block.
  dragStart(event) {
    this.carry(event.detail.item)
  }

  // Called by both "start" and the first "move", since a very quick drag can move before "start" arrives.
  carry(item) {
    if (!this.isSection(item) || this.carried) return

    this.carried = this.followers(item)
    this.carried.forEach((row) => { row.hidden = true })
  }

  // A heading may only be dropped just before another heading, or at the very end; anywhere else would
  // split a group and hand its remaining rows to the wrong heading.
  canDrop(event) {
    const { item, related, after } = event.detail
    if (!this.isSection(item)) return

    this.carry(item)
    const rows = this.visibleRows.filter((row) => row !== item)
    const index = rows.indexOf(related)
    if (index < 0) return

    const next = rows[after ? index + 1 : index]
    if (next && !this.isSection(next)) event.preventDefault()
  }

  dragEnd(event) {
    if (this.carried) {
      event.detail.item.after(...this.carried)
      this.carried.forEach((row) => { row.hidden = false })
      this.carried = null
    }
    this.renumber()
  }

  moveUp(event) {
    this.move(event, -1)
  }

  moveDown(event) {
    this.move(event, 1)
  }

  // The arrow keys on a row's grip: an ingredient moves one place, a heading moves with its rows past a whole group.
  move(event, direction) {
    event.preventDefault()
    const row = event.target.closest(ROW)
    this.isSection(row) ? this.moveGroup(row, direction) : this.moveRow(row, direction)
    this.renumber()
    row.querySelector("[data-handle]").focus()
  }

  moveRow(row, direction) {
    const neighbour = this.sibling(row, direction)
    if (neighbour) direction < 0 ? neighbour.before(row) : neighbour.after(row)
  }

  moveGroup(heading, direction) {
    const group = [ heading, ...this.followers(heading) ]
    if (direction < 0) {
      let first = this.sibling(heading, -1)
      if (!first) return
      while (!this.isSection(first) && this.sibling(first, -1)) first = this.sibling(first, -1)
      if (!this.isSection(first)) return // loose rows above every heading would join this one

      first.before(...group)
    } else {
      const nextHeading = this.sibling(group.at(-1), 1)
      if (!nextHeading) return
      ;[ nextHeading, ...this.followers(nextHeading) ].at(-1).after(...group)
    }
  }

  // --- helpers ---

  get visibleRows() {
    return this.itemTargets.filter((row) => !row.hidden)
  }

  isSection(row) {
    return row.hasAttribute("data-section")
  }

  // The rows under a heading, up to the next heading.
  followers(heading) {
    const rows = []
    for (let row = heading.nextElementSibling; row && !this.isSection(row); row = row.nextElementSibling) {
      if (!row.hidden) rows.push(row)
    }
    return rows
  }

  sibling(row, direction) {
    let next = direction < 0 ? row.previousElementSibling : row.nextElementSibling
    while (next && next.hidden) next = direction < 0 ? next.previousElementSibling : next.nextElementSibling
    return next
  }

  renumber() {
    this.itemTargets.forEach((row, index) => {
      row.querySelector("[data-nested-form-target='position']").value = index
    })
  }
}
