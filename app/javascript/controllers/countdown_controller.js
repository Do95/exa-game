import { Controller } from "@hotwired/stimulus"

// Countdown ring. The server sends the seconds left, so a page refresh keeps it in sync.
// With `submit`, the form with that id is sent once when the time runs out.
export default class extends Controller {
  static targets = ["arc", "label"]
  static values = { seconds: Number, total: Number, submit: String }

  connect() { this.start() }
  disconnect() { cancelAnimationFrame(this.frame) }
  secondsValueChanged() { if (this.arcTarget) this.start() }

  start() {
    cancelAnimationFrame(this.frame)
    this.deadline = Date.now() + this.secondsValue * 1000
    this.fired = false
    this.circumference = 2 * Math.PI * 40
    this.arcTarget.style.strokeDasharray = this.circumference
    this.lastSecond = null
    this.tick()
  }

  tick = () => {
    const left = Math.max(0, (this.deadline - Date.now()) / 1000)
    const total = this.totalValue || 1
    this.arcTarget.style.strokeDashoffset = this.circumference * (1 - Math.min(1, left / total))
    const s = Math.ceil(left)
    if (s !== this.lastSecond) { this.labelTarget.textContent = s; this.lastSecond = s }
    this.element.classList.toggle("low", left <= 5)
    if (left <= 0) { this.timeUp(); return }
    this.frame = requestAnimationFrame(this.tick)
  }

  timeUp() {
    if (this.fired || !this.submitValue) return
    this.fired = true
    const form = document.getElementById(this.submitValue)
    if (form) setTimeout(() => form.requestSubmit(), 300)
  }
}
