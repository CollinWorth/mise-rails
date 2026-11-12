import { Controller } from "@hotwired/stimulus"

// Keeps the screen on while cooking.
export default class extends Controller {
  connect() {
    this.request()
    document.addEventListener("visibilitychange", this.request)
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.request)
    this.lock?.release()
  }

  request = async () => {
    if (!("wakeLock" in navigator) || document.visibilityState !== "visible") return
    try { this.lock = await navigator.wakeLock.request("screen") } catch {}
  }
}
