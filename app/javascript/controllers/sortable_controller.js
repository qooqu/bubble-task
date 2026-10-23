import { Controller } from "@hotwired/stimulus"
import { destroy, patch } from "@rails/request.js"

// Drag and drop on the board: drop a worker or task onto another of the same kind to move it
// to that spot, or onto the trash to delete it. The server answers with the re-rendered board.
export default class extends Controller {
  static targets = [ "item" ]

  start(event) {
    this.dragged = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", "") // Firefox only starts a drag that carries data
  }

  end() {
    this.dragged = null
  }

  allowMove(event) {
    const target = event.currentTarget
    if (this.dragged && target !== this.dragged && target.dataset.group === this.dragged.dataset.group) {
      event.preventDefault()
    }
  }

  allowTrash(event) {
    if (this.dragged) event.preventDefault()
  }

  move(event) {
    event.preventDefault()
    const items = this.itemTargets.filter(item => item.dataset.group === this.dragged.dataset.group)
    const ids = items.map(item => item.dataset.id).filter(id => id !== this.dragged.dataset.id)
    ids.splice(items.indexOf(event.currentTarget), 0, this.dragged.dataset.id)

    patch(this.dragged.dataset.orderUrl, { body: { ids }, responseKind: "turbo-stream" })
  }

  trash(event) {
    event.preventDefault()
    destroy(this.dragged.dataset.url, { responseKind: "turbo-stream" })
  }
}
