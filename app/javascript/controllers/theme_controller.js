import { Controller } from "@hotwired/stimulus"

// Toggles dark mode; the choice lives in a cookie so the server renders the right class.
export default class extends Controller {
  toggle() {
    const dark = document.documentElement.classList.toggle("dark")
    document.cookie = `theme=${dark ? "dark" : "light"}; path=/; max-age=31536000; samesite=lax`
  }
}
