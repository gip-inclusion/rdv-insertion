import { Controller } from "@hotwired/stimulus";
import safeTippy from "../lib/safeTippy";

export default class extends Controller {
  showContent() {
    // Destroy any existing tooltip on this element first.
    // This is to avoid multiple tooltips on the same element.
    // It can happen if the tooltip content changes after a page refresh with turbo.
     /* eslint-disable no-underscore-dangle */
    if (this.element._tippy) {
      this.element._tippy.destroy();
    }
    /* eslint-enable no-underscore-dangle */
    const { tooltipContent, placement } = this.element.dataset;

    safeTippy(this.element, {
      content: tooltipContent,
      allowHTML: true,
      ...(placement ? { placement } : {}),
    });
  }
}
