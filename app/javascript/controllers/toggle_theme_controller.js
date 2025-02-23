import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-theme"
export default class extends Controller {
  connect() {
    console.log("Toggle theme controller connected :D");
  }
  change() {
    const html = document.documentElement
    const currentTheme = html.getAttribute('data-theme')
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'
    html.setAttribute('data-theme', newTheme)
    localStorage.setItem('theme', newTheme)
  }

  connect() {
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
      document.documentElement.setAttribute('data-theme', savedTheme)
    }
  }
}
