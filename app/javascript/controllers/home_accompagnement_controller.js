import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["stepImage", "stepInfo", "dot"];

  connect() {
    this.currentIndex = 0;
    this.touchStartX = null;
    this.touchStartY = null;
    this.touchMoveX = null;
    this.touchMoveY = null;
    this.autoAdvanceIntervalMs = 6000;

    this._deactivateAll();
    this._showIndex(0);

    // Touch listeners for swipe navigation
    this._onTouchStart = this.onTouchStart.bind(this);
    this._onTouchMove = this.onTouchMove.bind(this);
    this._onTouchEnd = this.onTouchEnd.bind(this);
    this.element.addEventListener("touchstart", this._onTouchStart, { passive: true });
    this.element.addEventListener("touchmove", this._onTouchMove, { passive: true });
    this.element.addEventListener("touchend", this._onTouchEnd, { passive: true });

    // Click listeners on step images
    this._onStepImageClick = this.onStepImageClick.bind(this);
    this.stepImageTargets.forEach(stepImage => {
      stepImage.addEventListener("click", this._onStepImageClick);
    });

    // Auto-advance
    this._startAutoAdvance();
  }

  disconnect() {
    this._stopAutoAdvance();

    if (this._onTouchStart) this.element.removeEventListener("touchstart", this._onTouchStart);
    if (this._onTouchMove) this.element.removeEventListener("touchmove", this._onTouchMove);
    if (this._onTouchEnd) this.element.removeEventListener("touchend", this._onTouchEnd);

    if (this._onStepImageClick) {
      this.stepImageTargets.forEach(stepImage => {
        stepImage.removeEventListener("click", this._onStepImageClick);
      });
    }
  }
  
  toggleStep(event) {
    event.preventDefault();

    const clickedDot = event.currentTarget;
    const index = this.dotTargets.indexOf(clickedDot);

    if (index === -1) return;

    this._showIndex(index);
    this._resetAutoAdvance();
  }

  onStepImageClick(event) {
    const clickedStep = event.currentTarget;
    const index = this.stepImageTargets.indexOf(clickedStep);
    if (index === -1) return;
    this._showIndex(index);
    this._resetAutoAdvance();
  }

  onTouchStart(event) {
    const touch = event.touches && event.touches[0];
    if (!touch) return;
    this.touchStartX = touch.clientX;
    this.touchStartY = touch.clientY;
    this.touchMoveX = null;
    this.touchMoveY = null;
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

    const horizontalThreshold = 40; // px

    if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > horizontalThreshold) {
      if (deltaX < 0) {
        this._next();
      } else {
        this._prev();
      }
      this._resetAutoAdvance();
    }

    this.touchStartX = null;
    this.touchStartY = null;
    this.touchMoveX = null;
    this.touchMoveY = null;
  }

  // Private helpers
  _count() {
    // Use the minimum length across targets to avoid out-of-bounds
    const counts = [this.stepImageTargets.length, this.stepInfoTargets.length, this.dotTargets.length].filter(n => typeof n === "number");
    return counts.length ? Math.min(...counts) : 0;
  }

  _deactivateAll() {
    this.stepImageTargets.forEach(stepImage => stepImage.classList.remove("active"));
    this.stepInfoTargets.forEach(stepInfo => stepInfo.classList.remove("active"));
    this.dotTargets.forEach(dot => dot.classList.remove("active"));
  }

  _showIndex(index) {
    const total = this._count();
    if (total === 0) return;

    // Wrap-around
    const wrappedIndex = ((index % total) + total) % total;

    this._deactivateAll();

    const stepImage = this.stepImageTargets[wrappedIndex];
    const stepInfo = this.stepInfoTargets[wrappedIndex];
    const dot = this.dotTargets[wrappedIndex];

    if (stepImage) stepImage.classList.add("active");
    if (stepInfo) stepInfo.classList.add("active");
    if (dot) dot.classList.add("active");

    this.currentIndex = wrappedIndex;
  }

  _next() {
    this._showIndex((this.currentIndex || 0) + 1);
  }

  _prev() {
    this._showIndex((this.currentIndex || 0) - 1);
  }

  _startAutoAdvance() {
    this._stopAutoAdvance();
    this._autoTimer = setInterval(() => {
      this._next();
    }, this.autoAdvanceIntervalMs);
  }

  _stopAutoAdvance() {
    if (this._autoTimer) {
      clearInterval(this._autoTimer);
      this._autoTimer = null;
    }
  }

  _resetAutoAdvance() {
    this._startAutoAdvance();
  }
}
