import { Controller } from "@hotwired/stimulus"

const STEPS = ["bubble-na", "bubble-00", "bubble-25", "bubble-50", "bubble-75", "bubble-100"]

// Fills a clicked bubble straight away instead of waiting for the server's board,
// which replaces it when it arrives. Mirrors Task#advance!, so change both together.
export default class extends Controller {
  advance({ currentTarget: bubble }) {
    const bubbles = [...bubble.closest("tr").querySelectorAll(".bubble")]
    const assigned = bubbles.find((other) => !other.classList.contains("bubble-na"))
    if (assigned && assigned !== bubble) return

    const step = STEPS.findIndex((name) => bubble.classList.contains(name))
    bubble.classList.replace(STEPS[step], STEPS[(step + 1) % STEPS.length])
  }
}
