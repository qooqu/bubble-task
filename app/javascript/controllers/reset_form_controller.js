import { Controller } from "@hotwired/stimulus"

// Clears an add form after Turbo submits it, so the next name can be typed straight away.
export default class extends Controller {
  reset(event) {
    if (event.detail.success) this.element.reset()
  }
}
