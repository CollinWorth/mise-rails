import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Drag-to-reorder for a list of rows, by their grip handles, with a finger or a mouse. The list's own controller
// decides what a move means: this one only reports "start", "move" (cancel it to refuse a drop spot) and "end".
export default class extends Controller {
  static values = { handle: { type: String, default: "[data-handle]" } }

  connect() {
    this.sortable = Sortable.create(this.element, {
      draggable: "[data-reorder-item]",
      handle: this.handleValue,
      animation: 150,
      forceFallback: true, // pointer-based dragging behaves the same on touch screens as with a mouse
      fallbackOnBody: true,
      ghostClass: "opacity-30",
      fallbackClass: "rounded-lg bg-background shadow-xl",
      onStart: (event) => this.dispatch("start", { detail: { item: event.item } }),
      onMove: (event) => !this.dispatch("move", { detail: { item: event.dragged, related: event.related, after: event.willInsertAfter }, cancelable: true }).defaultPrevented,
      onEnd: (event) => this.dispatch("end", { detail: { item: event.item } })
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }
}
