import { Controller } from "@hotwired/stimulus"

// Ticks off ingredients and steps while cooking. Ticks are remembered on this device, per recipe,
// and put back after the page refreshes (changing the scale re-renders the lists).
export default class extends Controller {
  static targets = [ "item" ]
  static values = { key: String }

  connect() {
    this.restore()
  }

  save() {
    const ticked = this.itemTargets.filter((item) => item.checked).map((item) => item.value)
    this.write(ticked)
  }

  restore() {
    const ticked = this.read()
    this.itemTargets.forEach((item) => { item.checked = ticked.includes(item.value) })
  }

  clear() {
    this.itemTargets.forEach((item) => { item.checked = false })
    this.write([])
  }

  get storageKey() {
    return `ticked:${this.keyValue}`
  }

  read() {
    try {
      return JSON.parse(localStorage.getItem(this.storageKey)) || []
    } catch {
      return []
    }
  }

  write(ticked) {
    try {
      ticked.length ? localStorage.setItem(this.storageKey, JSON.stringify(ticked)) : localStorage.removeItem(this.storageKey)
    } catch {
      // storage unavailable (private mode): ticks just last until the page changes
    }
  }
}
