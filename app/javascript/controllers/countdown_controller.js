import { Controller } from "@hotwired/stimulus"

// Counts down to a time as hours:minutes:seconds, like a guest sandbox's deletion.
export default class extends Controller {
  static values = { until: String }

  connect() {
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const seconds = Math.max(0, Math.floor((new Date(this.untilValue) - Date.now()) / 1000))
    const parts = [ Math.floor(seconds / 3600), Math.floor(seconds / 60) % 60, seconds % 60 ]
    this.element.textContent = parts.map(part => String(part).padStart(2, "0")).join(":")
  }
}
