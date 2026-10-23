import { Controller } from "@hotwired/stimulus"

// Keeps a <time> element's "about N hours" current while the page stays open.
// Mirrors BoardsHelper#hours_until, which renders the first value.
export default class extends Controller {
  connect() {
    this.update()
    this.timer = setInterval(() => this.update(), 60 * 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  update() {
    const hoursLeft = (new Date(this.element.dateTime) - Date.now()) / (60 * 60 * 1000)

    if (hoursLeft < 1) {
      this.element.textContent = "less than 1 hour"
    } else {
      const hours = Math.min(Math.round(hoursLeft), 24)
      this.element.textContent = `about ${hours} ${hours === 1 ? "hour" : "hours"}`
    }
  }
}
