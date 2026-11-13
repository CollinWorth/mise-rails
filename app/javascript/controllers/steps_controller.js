import { Controller } from "@hotwired/stimulus"

const ROW = "[data-steps-target='item']"
const TEXT = "[data-steps-target='text']"

// The instructions editor: a list of steps, each an auto-growing box. It keeps a hidden field holding the steps
// joined one per line, which is how the recipe stores them. Enter starts the next step (splitting at the cursor),
// Backspace at the start of a step joins it to the one above, and pasted lines become steps.
export default class extends Controller {
  static targets = ["list", "template", "item", "text", "number", "output"]

  connect() {
    this.growAll()
    this.sync()
  }

  add() {
    this.insert("").querySelector(TEXT).focus()
  }

  input(event) {
    this.grow(event.target)
    this.sync()
  }

  // Return splits the step at the cursor: the text after it becomes the next step.
  enter(event) {
    if (event.isComposing) return

    event.preventDefault()
    const box = event.target
    const rest = box.value.slice(box.selectionEnd)
    box.value = box.value.slice(0, box.selectionStart)
    this.grow(box)

    const next = this.insert(rest, box.closest(ROW)).querySelector(TEXT)
    next.focus()
    next.setSelectionRange(0, 0)
  }

  // Backspace at the very start joins this step onto the one above, as in a document.
  backspace(event) {
    const box = event.target
    if (event.key !== "Backspace" || box.selectionStart !== 0 || box.selectionEnd !== 0) return

    const row = box.closest(ROW)
    const above = row.previousElementSibling
    if (!above) return

    event.preventDefault()
    const aboveBox = above.querySelector(TEXT)
    const caret = aboveBox.value.length
    aboveBox.value += box.value
    row.remove()
    this.grow(aboveBox)
    aboveBox.focus()
    aboveBox.setSelectionRange(caret, caret)
    this.sync()
  }

  // Pasting several lines (a copied method) makes a step of each line.
  paste(event) {
    const lines = event.clipboardData.getData("text").split(/\r?\n/).map((line) => line.trim()).filter(Boolean)
    if (lines.length < 2) return

    event.preventDefault()
    const box = event.target
    const before = box.value.slice(0, box.selectionStart)
    const after = box.value.slice(box.selectionEnd)
    box.value = before + lines[0]
    this.grow(box)

    let row = box.closest(ROW)
    lines.slice(1).forEach((line, index) => {
      row = this.insert(index === lines.length - 2 ? line + after : line, row)
    })
    row.querySelector(TEXT).focus()
    this.sync()
  }

  remove(event) {
    event.target.closest(ROW).remove()
    if (!this.itemTargets.length) this.insert("")
    this.sync()
  }

  moveUp(event) {
    this.move(event, -1)
  }

  moveDown(event) {
    this.move(event, 1)
  }

  move(event, direction) {
    event.preventDefault()
    const row = event.target.closest(ROW)
    const neighbour = direction < 0 ? row.previousElementSibling : row.nextElementSibling
    if (neighbour) direction < 0 ? neighbour.before(row) : neighbour.after(row)
    row.querySelector("[data-handle]").focus()
    this.sync()
  }

  insert(text, after = null) {
    const row = this.templateTarget.content.firstElementChild.cloneNode(true)
    const box = row.querySelector(TEXT)
    box.value = text
    after ? after.after(row) : this.listTarget.append(row)
    this.grow(box)
    this.sync()
    return row
  }

  // The box is as tall as its text, so a long step never needs scrolling or a drag handle.
  grow(box) {
    box.style.height = "auto"
    box.style.height = `${box.scrollHeight}px`
  }

  growAll() {
    this.textTargets.forEach((box) => this.grow(box))
  }

  // Number the steps and refresh the hidden field the form submits.
  sync() {
    this.numberTargets.forEach((badge, index) => { badge.textContent = index + 1 })
    this.outputTarget.value = this.textTargets.map((box) => box.value.trim()).filter(Boolean).join("\n")
  }
}
