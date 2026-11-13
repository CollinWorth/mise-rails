import { Controller } from "@hotwired/stimulus"

// A note that picks tonight's dinner from a list; each tap swaps in a different one.
export default class extends Controller {
  static targets = ["name"]
  static values = { names: Array }

  roll() {
    const others = this.namesValue.filter((name) => name !== this.nameTarget.textContent)
    const next = others[Math.floor(Math.random() * others.length)]
    if (!next) return

    this.nameTarget.classList.add("opacity-0", "translate-y-1")
    setTimeout(() => {
      this.nameTarget.textContent = next
      this.nameTarget.classList.remove("opacity-0", "translate-y-1")
    }, 160)
  }
}
