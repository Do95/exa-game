import { Controller } from "@hotwired/stimulus"

// A new question or result screen: start at the top, with nothing left focused from the last one.
export default class extends Controller {
  connect() {
    if (window.scrollY > 0) window.scrollTo({ top: 0 })
    if (document.activeElement && document.activeElement !== document.body && !this.element.contains(document.activeElement)) {
      document.activeElement.blur()
    }
  }
}
