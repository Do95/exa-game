import { Controller } from "@hotwired/stimulus"

// A burst of confetti in the school colors when the element appears.
export default class extends Controller {
  static values = { amount: { type: Number, default: 90 } }

  connect() {
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) return
    if (this.element.dataset.confettiDone) return
    this.element.dataset.confettiDone = "1"
    const canvas = document.createElement("canvas")
    canvas.className = "confetti"
    document.body.appendChild(canvas)
    const ctx = canvas.getContext("2d"), dpr = window.devicePixelRatio || 1
    canvas.width = innerWidth * dpr; canvas.height = innerHeight * dpr
    const colors = ["#14315A", "#B22A2E", "#E8A317", "#168A5C", "#7FA3D6"]
    let parts = Array.from({ length: this.amountValue }, () => ({
      x: innerWidth / 2 + (Math.random() - .5) * 200, y: innerHeight / 3,
      vx: (Math.random() - .5) * 16, vy: Math.random() * -13 - 3, r: 4 + Math.random() * 6,
      c: colors[Math.floor(Math.random() * colors.length)], a: Math.random() * 6, life: 90 + Math.random() * 50
    }))
    const step = () => {
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0); ctx.clearRect(0, 0, innerWidth, innerHeight)
      parts = parts.filter(p => p.life-- > 0)
      for (const p of parts) {
        p.vy += .35; p.x += p.vx; p.y += p.vy; p.a += .2
        ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.a); ctx.fillStyle = p.c; ctx.globalAlpha = Math.min(1, p.life / 30)
        ctx.fillRect(-p.r / 2, -p.r / 4, p.r, p.r / 2); ctx.restore()
      }
      if (parts.length) requestAnimationFrame(step); else canvas.remove()
    }
    requestAnimationFrame(step)
  }
}
