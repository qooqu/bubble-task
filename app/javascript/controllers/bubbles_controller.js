import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const STEPS = ["bubble-na", "bubble-00", "bubble-25", "bubble-50", "bubble-75", "bubble-100"]

// Lets bubbles be clicked as fast as you like. Each click fills its bubble straight
// away, mirroring Task#advance!, so change both together. The clicks go to the server
// one at a time, and only the board sent back for the last one replaces the page's,
// so the board never jumps back to an earlier click. This sits above the board,
// not on it, so the queue survives the board being replaced.
export default class extends Controller {
  connect() {
    this.requests = Promise.resolve()
    this.pending = 0
  }

  advance(event) {
    event.preventDefault()
    this.fill(event.currentTarget)
    this.enqueue(event.currentTarget.form)
  }

  fill(bubble) {
    const bubbles = [...bubble.closest("tr").querySelectorAll(".bubble")]
    const assigned = bubbles.find((other) => !other.classList.contains("bubble-na"))
    if (assigned && assigned !== bubble) return

    const step = STEPS.findIndex((name) => bubble.classList.contains(name))
    bubble.classList.replace(STEPS[step], STEPS[(step + 1) % STEPS.length])
  }

  enqueue(form) {
    this.pending++
    this.element.ariaBusy = "true"
    this.requests = this.requests.then(() => this.submit(form)).catch(() => {}).finally(() => {
      if (--this.pending === 0) this.element.ariaBusy = null
    })
  }

  async submit(form) {
    const response = await fetch(form.action, {
      method: "POST", body: new FormData(form), headers: { Accept: "text/vnd.turbo-stream.html" }
    })
    const html = await response.text()
    if (this.pending === 1) Turbo.renderStreamMessage(html)
  }
}
