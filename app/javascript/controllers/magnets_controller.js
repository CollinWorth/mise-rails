import { Controller } from "@hotwired/stimulus"

// Magnets on the fridge door: drag a word with a pointer or finger, or move it with the arrow keys. Positions are kept as
// percentages of the door so they hold when the screen changes size. A word dropped close to the end of another snaps onto
// it, so a sentence lines up like real magnet poetry.
export default class extends Controller {
  static targets = ["magnet", "hint"]

  connect() {
    this.top = 10
    this.drag = null
  }

  down(event) {
    if (event.button > 0) return

    const el = event.currentTarget
    const rect = el.getBoundingClientRect()
    this.drag = { el, dx: event.clientX - rect.left, dy: event.clientY - rect.top }
    el.setPointerCapture(event.pointerId)
    el.style.zIndex = ++this.top
    el.classList.remove("magnet-in", "magnet-settle")
    el.classList.add("magnet-lifted")
    this.dismissHint()
  }

  move(event) {
    if (!this.drag || this.drag.el !== event.currentTarget) return

    const door = this.element.getBoundingClientRect()
    this.place(this.drag.el, event.clientX - door.left - this.drag.dx, event.clientY - door.top - this.drag.dy)
  }

  up(event) {
    if (!this.drag || this.drag.el !== event.currentTarget) return

    const el = this.drag.el
    this.drag = null
    el.classList.remove("magnet-lifted")
    this.snap(el)
    void el.offsetWidth // restart the settle animation
    el.classList.add("magnet-settle")
  }

  key(event) {
    const step = event.shiftKey ? 32 : 8
    const moves = { ArrowLeft: [-step, 0], ArrowRight: [step, 0], ArrowUp: [0, -step], ArrowDown: [0, step] }
    const move = moves[event.key]
    if (!move) return

    event.preventDefault()
    const el = event.currentTarget
    const spot = this.spot(el)
    this.place(el, spot.left + move[0], spot.top + move[1])
    this.dismissHint()
  }

  // Where a magnet is, in pixels from the door's top left.
  spot(el) {
    const door = this.element.getBoundingClientRect()
    const rect = el.getBoundingClientRect()
    return { left: rect.left - door.left, top: rect.top - door.top, width: rect.width, height: rect.height }
  }

  place(el, left, top) {
    const door = this.element.getBoundingClientRect()
    const clampedLeft = Math.min(Math.max(left, 0), door.width - el.offsetWidth)
    const clampedTop = Math.min(Math.max(top, 0), door.height - el.offsetHeight)
    el.style.left = `${(clampedLeft / door.width) * 100}%`
    el.style.top = `${(clampedTop / door.height) * 100}%`
  }

  snap(el) {
    const mine = this.spot(el)
    for (const other of this.magnetTargets) {
      if (other === el) continue

      const theirs = this.spot(other)
      if (Math.abs(mine.top - theirs.top) > 14) continue

      if (Math.abs(mine.left - (theirs.left + theirs.width + 3)) < 16) return this.place(el, theirs.left + theirs.width + 3, theirs.top)
      if (Math.abs(mine.left + mine.width + 3 - theirs.left) < 16) return this.place(el, theirs.left - mine.width - 3, theirs.top)
    }
  }

  dismissHint() {
    if (this.hasHintTarget) this.hintTarget.classList.add("opacity-0")
  }
}
