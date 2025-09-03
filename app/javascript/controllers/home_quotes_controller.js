import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quoteCard", "slideIndicator"]

  connect() {
    const activeIndex = this.quoteCardTargets.findIndex(card => card.classList.contains("active"))
    this.currentIndex = activeIndex >= 0 ? activeIndex : 0
    this.touchStartX = null
    this.touchStartY = null
    this.touchMoveX = null
    this.touchMoveY = null

    this.autoRotateIntervalMs = 6000
    this.startAutoRotate()
  }

  disconnect() {
    this.stopAutoRotate()
  }

  showQuote(event) {
    const clickedIndex = Array.from(this.slideIndicatorTargets).indexOf(event.currentTarget)
    this.showIndex(clickedIndex)
    this.resetAutoRotate()
  }

  onTouchStart(event) {
    if (event.touches && event.touches.length === 1) {
      this.touchStartX = event.touches[0].clientX
      this.touchStartY = event.touches[0].clientY
      this.touchMoveX = null
      this.touchMoveY = null
      this.stopAutoRotate()
    }
  }

  onTouchMove(event) {
    if (event.touches && event.touches.length === 1) {
      this.touchMoveX = event.touches[0].clientX
      this.touchMoveY = event.touches[0].clientY
    }
  }

  onTouchEnd() {
    if (this.touchStartX == null) return

    const endX = this.touchMoveX != null ? this.touchMoveX : this.touchStartX
    const endY = this.touchMoveY != null ? this.touchMoveY : this.touchStartY
    const deltaX = endX - this.touchStartX
    const deltaY = endY - this.touchStartY

    const threshold = 40

    if (Math.abs(deltaX) >= threshold && Math.abs(deltaX) > Math.abs(deltaY)) {
      if (deltaX < 0) {
        this.showNext()
      } else {
        this.showPrev()
      }
    }

    this.touchStartX = null
    this.touchStartY = null
    this.touchMoveX = null
    this.touchMoveY = null

    this.startAutoRotate()
  }

  showIndex(index) {
    const clampedIndex = ((index % this.quoteCardTargets.length) + this.quoteCardTargets.length) % this.quoteCardTargets.length

    this.quoteCardTargets.forEach(quoteCard => {
      quoteCard.classList.remove("active")
    })

    this.slideIndicatorTargets.forEach(indicator => {
      indicator.classList.remove("active")
    })

    this.quoteCardTargets[clampedIndex].classList.add("active")
    if (this.slideIndicatorTargets[clampedIndex]) {
      this.slideIndicatorTargets[clampedIndex].classList.add("active")
    }

    this.currentIndex = clampedIndex
  }

  showNext() {
    this.showIndex(this.currentIndex + 1)
  }

  showPrev() {
    this.showIndex(this.currentIndex - 1)
  }

  startAutoRotate() {
    if (this.autoRotateTimer) {
      clearInterval(this.autoRotateTimer)
      this.autoRotateTimer = null
    }
    if (this.quoteCardTargets.length <= 1) return
    this.autoRotateTimer = setInterval(() => {
      this.showNext()
    }, this.autoRotateIntervalMs)
  }

  stopAutoRotate() {
    if (this.autoRotateTimer) {
      clearInterval(this.autoRotateTimer)
      this.autoRotateTimer = null
    }
  }

  resetAutoRotate() {
    this.stopAutoRotate()
    this.startAutoRotate()
  }
} 