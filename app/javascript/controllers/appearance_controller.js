import { Controller } from "@hotwired/stimulus"

// Shows the appearance choices straight away (the form saves them a moment later): which theme is in use
// is the pinned light or dark one, or, with "match my device", whichever the device is set to right now.
export default class extends Controller {
  preview() {
    const choice = (name) => this.element.querySelector(`input[name="user[${name}]"]:checked`)?.value
    const appearance = choice("appearance")
    const lightTheme = choice("light_theme")
    const darkTheme = choice("dark_theme")
    const dark = appearance === "dark" || (appearance === "auto" && matchMedia("(prefers-color-scheme: dark)").matches)

    const root = document.documentElement
    Object.assign(root.dataset, { appearance, lightTheme, darkTheme, palette: dark ? darkTheme : lightTheme })
    root.classList.toggle("dark", dark)
  }
}
