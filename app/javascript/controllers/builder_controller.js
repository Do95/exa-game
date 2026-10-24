import { Controller } from "@hotwired/stimulus"

// "Build the sentence": tap a word to add it to the sentence, tap it again to send it back.
export default class extends Controller {
  static targets = ["answer", "bank", "response", "submit"]

  pick(event) {
    const tile = event.currentTarget
    if (tile.parentElement === this.answerTarget) this.putBack(tile)
    else this.answerTarget.appendChild(tile)
    this.update()
  }

  clear() {
    this.answerTarget.querySelectorAll(".tile").forEach(tile => this.putBack(tile))
    this.update()
  }

  // Words go back to their first place, so the bank doesn't reshuffle.
  putBack(tile) {
    const after = [...this.bankTarget.children].find(t => Number(t.dataset.order) > Number(tile.dataset.order))
    this.bankTarget.insertBefore(tile, after || null)
  }

  update() {
    const words = [...this.answerTarget.querySelectorAll(".tile")].map(t => t.dataset.word)
    this.responseTarget.value = words.join(" ")
    this.submitTarget.disabled = words.length === 0
  }
}
