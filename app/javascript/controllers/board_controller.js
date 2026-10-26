import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const STEPS = ["bubble-na", "bubble-00", "bubble-25", "bubble-50", "bubble-75", "bubble-100"]

// Shows every board action's result straight away instead of waiting for the server.
// Each action changes the page to what the server is going to make of it, then queues
// its request. Requests go one at a time, and only the board sent back for the last
// one replaces the page's, so the board never jumps back to an earlier action's state.
// This sits above the board, not on it, so the queue survives the board being replaced.
export default class extends Controller {
  static targets = [ "board", "item" ]

  connect() {
    this.requests = Promise.resolve()
    this.pending = 0
    this.element.ariaBusy = null
  }

  // A click on a task's bubble in a worker's column. Mirrors Task#advance!, so change both together.
  advance(event) {
    event.preventDefault()
    const bubble = event.currentTarget
    const bubbles = [...bubble.closest("tr").querySelectorAll(".bubble")]
    const assigned = bubbles.find((other) => !other.classList.contains("bubble-na"))
    if (assigned && assigned !== bubble) return

    const step = STEPS.findIndex((name) => bubble.classList.contains(name))
    bubble.classList.replace(STEPS[step], STEPS[(step + 1) % STEPS.length])
    this.submit(bubble.form)
  }

  addWorker(event) {
    this.add(event, (name) => {
      this.boardTarget.tHead.rows[0].append(this.header(name, "col"))
      for (const row of this.boardTarget.tBodies[0].rows) row.append(this.placeholderBubble())
    })
  }

  addTask(event) {
    this.add(event, (name) => {
      const row = this.boardTarget.tBodies[0].insertRow()
      row.append(this.header(name, "row"))
      for (let i = 1; i < this.boardTarget.tHead.rows[0].cells.length; i++) row.append(this.placeholderBubble())
    })
  }

  // Drag and drop: drop a worker or task onto another of the same kind to move it
  // to that spot, or onto the trash to delete it.
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
    const target = event.currentTarget
    const items = this.itemTargets.filter(item => item.dataset.group === this.dragged.dataset.group)
    const ids = items.map(item => item.dataset.id).filter(id => id !== this.dragged.dataset.id)
    ids.splice(items.indexOf(target), 0, this.dragged.dataset.id)

    const movingUp = items.indexOf(this.dragged) > items.indexOf(target)
    const targetCells = this.cellsOf(target)
    this.cellsOf(this.dragged).forEach((cell, i) => movingUp ? targetCells[i].before(cell) : targetCells[i].after(cell))

    const body = new FormData()
    ids.forEach(id => body.append("ids[]", id))
    this.enqueue(this.dragged.dataset.orderUrl, "PATCH", body)
  }

  trash(event) {
    event.preventDefault()
    this.cellsOf(this.dragged).forEach(cell => cell.remove())
    this.enqueue(this.dragged.dataset.url, "DELETE")
  }

  // private

  add(event, guess) {
    event.preventDefault()
    const form = event.currentTarget
    const name = form.querySelector("input[type=text]").value.trim()
    if (!name) return

    guess(name)
    this.submit(form)
    form.reset()
  }

  // The cells that make up a task's row or a worker's column.
  cellsOf(item) {
    if (item.dataset.group === "tasks") return [ item.closest("tr") ]

    return [...this.boardTarget.rows].map(row => row.cells[item.cellIndex])
  }

  header(name, scope) {
    const header = document.createElement("th")
    header.scope = scope
    header.textContent = name
    return header
  }

  // Stands in for a new worker's or task's bubble until the server's board arrives.
  placeholderBubble() {
    const cell = document.createElement("td")
    const bubble = document.createElement("button")
    bubble.className = "bubble bubble-na"
    bubble.disabled = true
    cell.append(bubble)
    return cell
  }

  submit(form) {
    this.enqueue(form.action, "POST", new FormData(form))
  }

  enqueue(url, method, body) {
    this.pending++
    this.element.ariaBusy = "true"
    this.requests = this.requests.then(() => this.send(url, method, body)).catch(() => this.reload()).finally(() => {
      if (--this.pending === 0) this.element.ariaBusy = null
    })
  }

  async send(url, method, body) {
    // There's no token when forgery protection is off, as in tests.
    const token = document.querySelector("meta[name=csrf-token]")?.content ?? ""
    const response = await fetch(url, {
      method, body, headers: { Accept: "text/vnd.turbo-stream.html", "X-CSRF-Token": token }
    })
    if (!response.ok || response.redirected) throw new Error(`Board request failed: ${response.status}`)

    const html = await response.text()
    if (this.pending === 1) Turbo.renderStreamMessage(html)
  }

  // A request that didn't go through leaves the page ahead of the server, so load the
  // page again to show the board as it really is (or the login page).
  reload() {
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
