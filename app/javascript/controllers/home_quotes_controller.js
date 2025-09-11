import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["quoteCard", "slideIndicator"];

  connect() {
    const activeIndex = this.quoteCardTargets.findIndex(card => card.classList.contains("active"));
    this.currentIndex = activeIndex >= 0 ? activeIndex : 0;

    this.autoAdvanceIntervalMs = 6000;
    this.autoRotateIntervalMs = this.autoAdvanceIntervalMs;
    this.horizontalSwipeThresholdPx = 40;

    this.#showIndex(this.currentIndex);
    this.#startAutoAdvance();
  }

  disconnect() {
    this.#stopAutoAdvance();
  }

  showQuote(event) {
    event.preventDefault?.();

    const clickedDot = event.currentTarget;
    const index = this.slideIndicatorTargets.indexOf(clickedDot);

    this.#showIndex(index);
    this.#startAutoAdvance();
  }

  onTouchStart(event) {
    const touch = event.touches && event.touches[0];
    if (!touch) return;

    this.touchStartX = touch.clientX;
    this.touchStartY = touch.clientY;
    this.touchMoveX = null;
    this.touchMoveY = null;

    this.#stopAutoAdvance();
  }

  onTouchMove(event) {
    const touch = event.touches && event.touches[0];
    if (!touch) return;

    this.touchMoveX = touch.clientX;
    this.touchMoveY = touch.clientY;
  }

  onTouchEnd() {
    if (this.touchStartX == null || this.touchStartY == null) return;

    const endX = this.touchMoveX != null ? this.touchMoveX : this.touchStartX;
    const endY = this.touchMoveY != null ? this.touchMoveY : this.touchStartY;

    const deltaX = endX - this.touchStartX;
    const deltaY = endY - this.touchStartY;

    const isHorizontalMovement = Math.abs(deltaX) > Math.abs(deltaY);
    const exceedsThreshold = Math.abs(deltaX) >= this.horizontalSwipeThresholdPx;
    const isSwipeLeft = deltaX < 0;

    if (isHorizontalMovement && exceedsThreshold) {
      if (isSwipeLeft) {
        this.#next();
      } else {
        this.#prev();
      }
    }

    this.touchStartX = null;
    this.touchStartY = null;
    this.touchMoveX = null;
    this.touchMoveY = null;

    // Resume the auto-advance after touch ends, regardless of swipe detection
    this.#startAutoAdvance();
  }

  // Public compatibility wrappers
  showIndex(index) {
    this.#showIndex(index);
  }

  showNext() {
    this.#next();
  }

  showPrev() {
    this.#prev();
  }

  startAutoRotate() {
    this.#startAutoAdvance();
  }

  stopAutoRotate() {
    this.#stopAutoAdvance();
  }

  resetAutoRotate() {
    this.#stopAutoAdvance();
    this.#startAutoAdvance();
  }

  #count() {
    return this.quoteCardTargets.length;
  }

  #resetSlides() {
    this.quoteCardTargets.forEach(quoteCard => quoteCard.classList.remove("active"));
    this.slideIndicatorTargets.forEach(indicator => indicator.classList.remove("active"));
  }

  #showIndex(index) {
    const total = this.#count();
    if (total === 0) return;

    const newIndex = ((index % total) + total) % total;

    this.#resetSlides();

    this.quoteCardTargets[newIndex]?.classList.add("active");
    this.slideIndicatorTargets[newIndex]?.classList.add("active");

    this.currentIndex = newIndex;
  }

  #next() {
    this.#showIndex((this.currentIndex || 0) + 1);
  }

  #prev() {
    this.#showIndex((this.currentIndex || 0) - 1);
  }

  #startAutoAdvance() {
    this.#stopAutoAdvance();
    if (this.#count() <= 1) return;

    this.autoTimer = setInterval(() => {
      this.#next();
    }, this.autoAdvanceIntervalMs);
  }

  #stopAutoAdvance() {
    if (this.autoTimer) {
      clearInterval(this.autoTimer);
      this.autoTimer = null;
    }
  }
} 